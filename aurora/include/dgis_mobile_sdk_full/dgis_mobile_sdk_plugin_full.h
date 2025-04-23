#pragma once

#ifdef PLUGIN_IMPL
#	define PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#	define PLUGIN_EXPORT
#endif

#include <flutter/plugin_registrar.h>
#include <flutter/flutter_aurora.h>
#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

using EncodableValue = flutter::EncodableValue;
using MethodChannel = flutter::MethodChannel<EncodableValue>;
using MethodCall = flutter::MethodCall<EncodableValue>;
using MethodResult = flutter::MethodResult<EncodableValue>;

class PLUGIN_EXPORT DgisMobileSdkPluginFull : public flutter::Plugin
{
public:
	static void RegisterWithRegistrar(flutter::PluginRegistrar * registrar);

private:
	explicit DgisMobileSdkPluginFull(flutter::PluginRegistrar * registrar, std::unique_ptr<MethodChannel> methodChannel);

private:
	class Impl;
	std::unique_ptr<Impl, void (*)(Impl *)> impl_;
};