#pragma once

#include "MapSurfaceBuffer.h"

#include <cstddef>
#include <functional>
#include <memory>

void map_surface_set_buffer_available_callback(
	std::size_t map_surface_id,
	std::function<void(void *)> callback,
	void * context);

[[nodiscard]] MapSurfaceBuffer map_surface_surface_buffer(std::size_t map_surface_id);

[[nodiscard]] std::shared_ptr<void> map_surface_lock(std::size_t map_surface_id);