#import "FlutterMetalTexture.h"
#import "MobileSDKPlugin.h"

@interface MobileSDKPlugin ()
@property(nonatomic, strong) id<MTLDevice> device;
@property(nonatomic, assign) CVMetalTextureCacheRef textureCache;
@property(nonatomic, strong) id<FlutterTextureRegistry> flutterTextureRegistry;
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, FlutterMetalTexture *> * renders;
@property(nonatomic, strong) FlutterMethodChannel * channel;

extern NSInteger const kDefaultSize;

@end

@implementation MobileSDKPlugin

NSInteger const kDefaultSize = 100;

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
{
	MobileSDKPlugin * instance = [[MobileSDKPlugin alloc] initWithFlutterPluginRegistrar:registrar];
	[registrar addMethodCallDelegate:instance channel:instance.channel];
}

- (instancetype)initWithFlutterPluginRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar
{
	self = [super init];
	if (self)
	{
		self.device = MTLCreateSystemDefaultDevice();
		if (!self.device)
		{
			@throw [NSException exceptionWithName:@"InitializationError"
										   reason:@"Failed creating default metal device"
										 userInfo:nil];
		}

		CVReturn status = CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, self.device, nil, &_textureCache);
		if (status != kCVReturnSuccess)
		{
			@throw [NSException exceptionWithName:@"InitializationError"
										   reason:@"Failed to create texture cache"
										 userInfo:nil];
		}

		self.flutterTextureRegistry = [registrar textures];
		if (!self.flutterTextureRegistry)
		{
			@throw [NSException exceptionWithName:@"InitializationError"
										   reason:@"Could not get flutter texture registry"
										 userInfo:nil];
		}
		self.renders = [NSMutableDictionary dictionary];
		self.channel = [FlutterMethodChannel methodChannelWithName:@"flutter_map_surface_plugin"
												   binaryMessenger:[registrar messenger]];
	}
	return self;
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result
{
	@autoreleasepool
	{
		NSDictionary * arguments = call.arguments;

		if ([call.method isEqualToString:@"setSurface"])
		{
			NSNumber * mapSurfaceId = arguments[@"mapSurfaceId"];
			if (!mapSurfaceId)
			{
				return;
			}
			NSInteger mapSurfaceIdInt = [mapSurfaceId integerValue];

			FlutterMetalTexture * texture = [[FlutterMetalTexture alloc] initWithDevice:self.device
																		   textureCache:self.textureCache
																 flutterTextureRegistry:self.flutterTextureRegistry
																				  width:kDefaultSize
																				 height:kDefaultSize];

			NSInteger textureId = [self.flutterTextureRegistry registerTexture:texture];
			texture.flutterTextureId = textureId;

			[texture setMetalTextureToMapWithSurfaceId:mapSurfaceIdInt
									  flutterTextureId:textureId
												 width:kDefaultSize
												height:kDefaultSize];

			NSNumber * registeredTextureId = @(texture.flutterTextureId);
			self.renders[registeredTextureId] = texture;
			result(registeredTextureId);
		}
		else if ([call.method isEqualToString:@"updateSurface"])
		{
			result(nil);
			return;
		}
		else if ([call.method isEqualToString:@"getScreenFps"])
		{
			NSInteger refreshRate = [UIScreen mainScreen].maximumFramesPerSecond;
			result(@(refreshRate));
			return;
		}
		else if ([call.method isEqualToString:@"dispose"])
		{
			NSNumber * textureId = arguments[@"textureId"];
			if (textureId)
			{
				FlutterMetalTexture * texture = self.renders[textureId];
				if (texture)
				{
					[texture.lock lock];
					texture.flutterTextureId = NSNotFound;
					[texture.lock unlock];
				}

				[self.renders removeObjectForKey:textureId];
				[self.flutterTextureRegistry unregisterTexture:[textureId unsignedIntegerValue]];
			}
			if (_textureCache)
			{
				CVMetalTextureCacheFlush(_textureCache, 0);
			}
		}
		else
		{
			result(FlutterMethodNotImplemented);
		}
	}
}

- (void)dealloc
{
	[self cleanupResources];
}

- (void)cleanupResources
{
	[self.renders removeAllObjects];

	if (_textureCache)
	{
		CFRelease(_textureCache);
		_textureCache = nil;
	}

	self.device = nil;
	self.flutterTextureRegistry = nil;
	self.channel = nil;
}

@end
