#include <dgis_mobile_sdk_full/dgis_mobile_sdk_plugin_full.h>

#include <MapSurfaceUtils.h>

#include <flutter_texture_registrar.h>
#include <flutter/flutter_aurora.h>

#include <algorithm>
#include <cstdint>
#include <memory>
#include <vector>

namespace Channels
{

constexpr auto Methods = "flutter_map_surface_plugin";

} // namespace Channels

namespace Methods
{

// Названия методов, которые вызываются из Dart с помощью механизма Flutter channels.
constexpr auto SetSurface = "setSurface";
constexpr auto UpdateSurface = "updateSurface";
constexpr auto Dispose = "dispose";

} // namespace Methods

/**
 * @brief Класс MapSurfacePixelBufferTexture связывает MapSurface, на который рендерит движок Zenith, с текстурой
 * Flutter, отображаемой в приложении на Dart.
 *
 * С одной стороны, он получает уведомления от MapSurface о готовности буфера (см.
 * MapSurface::set_buffer_available_callback), а с другой — уведомляет Flutter о готовности этого буфера (см.
 * TextureRegistrar::MarkTextureFrameAvailable). Когда Flutter запрашивает следующий буфер, класс читает данные из
 * MapSurface и передаёт их во Flutter.
 */
class MapSurfacePixelBufferTexture : public std::enable_shared_from_this<MapSurfacePixelBufferTexture>
{
	MapSurfacePixelBufferTexture() = default;

public:
	[[nodiscard]] static std::shared_ptr<MapSurfacePixelBufferTexture> create(
		const std::int64_t map_surface_id,
		flutter::PluginRegistrar * registrar)
	{
		auto texture = std::shared_ptr<MapSurfacePixelBufferTexture>(new MapSurfacePixelBufferTexture());
		if (texture->init(map_surface_id, registrar))
		{
			return texture;
		}
		return nullptr;
	}

	~MapSurfacePixelBufferTexture()
	{
		release();
	}

	[[nodiscard]] std::int64_t map_surface_id() const noexcept
	{
		return map_surface_id_;
	}

	[[nodiscard]] std::int64_t flutter_texture_id() const noexcept
	{
		return flutter_texture_id_;
	}

private:
	[[nodiscard]] bool init(const std::int64_t map_surface_id, flutter::PluginRegistrar * registrar)
	{
		self_weak_ = shared_from_this();

		map_surface_id_ = map_surface_id;

		map_surface_lock_ = map_surface_lock(static_cast<std::size_t>(map_surface_id));
		if (!map_surface_lock_)
		{
			return false;
		}

		registrar_ = registrar;

		flutter_texture_ = std::make_unique<flutter::TextureVariant>(flutter::PixelBufferTexture(
			[self_weak = self_weak_](size_t, size_t) -> const FlutterDesktopPixelBuffer *
			{
				if (auto self = self_weak.lock())
				{
					return self->on_flutter_buffer_requested();
				}
				return nullptr;
			}));

		flutter_texture_id_ = registrar->texture_registrar()->RegisterTexture(flutter_texture_.get());

		if (flutter_texture_id_ == -1)
		{
			return false;
		}

		map_surface_set_buffer_available_callback(
			static_cast<std::size_t>(map_surface_id),
			[self_weak = self_weak_]([[maybe_unused]] void * context)
			{
				if (auto self = self_weak.lock())
				{
					self->on_map_surface_buffer_ready();
				}
			},
			nullptr);

		return true;
	}

	void release()
	{
		if (flutter_texture_id_ == -1)
		{
			return;
		}

		map_surface_set_buffer_available_callback(static_cast<std::size_t>(map_surface_id_), nullptr, nullptr);
		registrar_->texture_registrar()->UnregisterTexture(flutter_texture_id_);
	}

	void on_map_surface_buffer_ready()
	{
		registrar_->texture_registrar()->MarkTextureFrameAvailable(flutter_texture_id_);
	}

	[[nodiscard]] const FlutterDesktopPixelBuffer * on_flutter_buffer_requested()
	{
		const auto map_surface_buffer = map_surface_surface_buffer(static_cast<std::size_t>(map_surface_id_));

		if (!map_surface_buffer.data)
		{
			return nullptr;
		}

		flutter_buffer_.width = map_surface_buffer.width;
		flutter_buffer_.height = map_surface_buffer.height;
		flutter_buffer_.buffer = map_surface_buffer.data;
		flutter_buffer_.release_callback = nullptr;

		return &flutter_buffer_;
	}

private:
	std::weak_ptr<MapSurfacePixelBufferTexture> self_weak_;
	std::shared_ptr<void> map_surface_lock_;
	std::int64_t map_surface_id_ = 0;
	flutter::PluginRegistrar * registrar_;
	std::unique_ptr<flutter::TextureVariant> flutter_texture_;
	FlutterDesktopPixelBuffer flutter_buffer_;
	std::int64_t flutter_texture_id_ = -1;
};

class DgisMobileSdkPluginFull::Impl
{
public:
	explicit Impl(flutter::PluginRegistrar * registrar, std::unique_ptr<MethodChannel> methodChannel)
		: registrar_{registrar}
		, methodChannel_{std::move(methodChannel)}
	{
		methodChannel_->SetMethodCallHandler(
			[this](const MethodCall & call, std::unique_ptr<MethodResult> result)
			{
				if (!call.arguments())
				{
					result->Error("NO_ARGS", "No arguments received");
					return;
				}

				const EncodableValue & arguments = *call.arguments();

				const auto args_map = std::get_if<flutter::EncodableMap>(&arguments);
				if (!args_map)
				{
					result->Error("ARG_ERROR", "Arguments are not a map/dictionary");
					return;
				}

				if (call.method_name().compare(Methods::SetSurface) == 0)
				{
					const auto args_map_iter = args_map->find(EncodableValue("mapSurfaceId"));
					if (args_map_iter == args_map->end())
					{
						result->Error("ARG_ERROR", "mapSurfaceId not found");
						return;
					}

					const auto * map_surface_id = std::get_if<std::int64_t>(&args_map_iter->second);
					if (!map_surface_id)
					{
						result->Error("ARG_ERROR", "mapSurfaceId is not int64_t");
						return;
					}

					if (*map_surface_id <= 0)
					{
						result->Error("ARG_ERROR", "incorrect mapSurfaceId");
						return;
					}

					if (std::any_of(
							textures_.begin(),
							textures_.end(),
							[id = *map_surface_id](const auto & texture)
							{
								return texture->map_surface_id() == id;
							}))
					{
						result->Error("ARG_ERROR", "texture has been already registered");
						return;
					}

					auto texture = MapSurfacePixelBufferTexture::create(*map_surface_id, registrar_);
					if (!texture)
					{
						result->Error("ARG_ERROR", "couldn't register texture");
						return;
					}

					textures_.emplace_back(std::move(texture));

					result->Success(textures_.back()->flutter_texture_id());
				}
				else if (call.method_name().compare(Methods::UpdateSurface) == 0)
				{
					// Ничего не делаем так как данный метод вызывается при изменение размера, но наш код никак не
					// влияет на размер, наш код только прокидывает буфер из MapSurface во Flutter,
					// а размер фактически меняется во MapSuface::resize_surface, который вызывается из Flutter
					// map_widget.
					result->Success();
				}
				else if (call.method_name().compare(Methods::Dispose) == 0)
				{
					const auto args_map_iter = args_map->find(EncodableValue("textureId"));
					if (args_map_iter == args_map->end())
					{
						result->Error("ARG_ERROR", "textureId not found");
						return;
					}

					const auto * texture_id = std::get_if<int>(&args_map_iter->second);
					if (!texture_id)
					{
						result->Error("ARG_ERROR", "textureId is not int");
						return;
					}

					textures_.erase(
						std::remove_if(
							textures_.begin(),
							textures_.end(),
							[id = *texture_id](const auto & texture)
							{
								return texture->flutter_texture_id() == id;
							}),
						textures_.end());

					result->Success();
				}
				else
				{
					result->NotImplemented();
				}
			});
	}

private:
	flutter::PluginRegistrar * registrar_;
	std::unique_ptr<MethodChannel> methodChannel_;
	std::vector<std::shared_ptr<MapSurfacePixelBufferTexture>> textures_;
};

void DgisMobileSdkPluginFull::RegisterWithRegistrar(flutter::PluginRegistrar * registrar)
{
	auto methodChannel = std::make_unique<MethodChannel>(
		registrar->messenger(),
		Channels::Methods,
		&flutter::StandardMethodCodec::GetInstance());

	auto plugin = std::unique_ptr<DgisMobileSdkPluginFull>(new DgisMobileSdkPluginFull(registrar, std::move(methodChannel)));

	registrar->AddPlugin(std::move(plugin));
}

DgisMobileSdkPluginFull::DgisMobileSdkPluginFull(
	flutter::PluginRegistrar * registrar,
	std::unique_ptr<MethodChannel> methodChannel)
	: impl_(
		new Impl(registrar, std::move(methodChannel)),
		[](Impl * ptr)
		{
			delete ptr;
		})
{
}