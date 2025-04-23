#pragma once

#include <cstdint>

struct MapSurfaceBuffer
{
	unsigned width{};
	unsigned height{};
	const std::uint8_t * data{};
};