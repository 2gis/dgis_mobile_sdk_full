#import "FlutterMetalTexture.h"

#import <PlatformCDart/MetalDrawablePresenter.h>
#import <PlatformCDart/Util.h>

@interface MetalDrawablePresenterImpl : NSObject <MetalDrawablePresenter>

@property(nonatomic, weak) id<FlutterTextureRegistry> flutterTextureRegistry;
@property(nonatomic, strong) NSLock * lock;
@property(nonatomic, assign) NSInteger flutterTextureId;

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)flutterTextureRegistry lock:(NSLock *)lock;
- (void)setFlutterTextureId:(NSInteger)textureId;

@end

@implementation MetalDrawablePresenterImpl

- (instancetype)initWithTextureRegistry:(id<FlutterTextureRegistry>)flutterTextureRegistry lock:(NSLock *)lock
{
	self = [super init];
	if (self)
	{
		_flutterTextureRegistry = flutterTextureRegistry;
		_lock = lock;
		_flutterTextureId = NSNotFound;
	}
	return self;
}

- (void)setFlutterTextureId:(NSInteger)textureId
{
	[self.lock lock];
	_flutterTextureId = textureId;
	[self.lock unlock];
}

- (void)present
{
	dispatch_async(dispatch_get_main_queue(), ^{
		if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
		{
			return;
		}

		[self.lock lock];
		NSInteger textureId = self.flutterTextureId;
		id<FlutterTextureRegistry> registry = self.flutterTextureRegistry;
		[self.lock unlock];

		if (!registry || textureId == NSNotFound)
		{
			return;
		}

		[registry textureFrameAvailable:textureId];
	});
}

@end

@interface FlutterMetalTexture ()
@property(nonatomic, strong) MetalDrawablePresenterImpl * presenter;
@property(nonatomic, strong) id<MetalLayerProviderInstance> metalLayerProvider;
@property(nonatomic, strong) id<FlutterTextureRegistry> flutterTextureRegistry;
@end

@implementation FlutterMetalTexture

- (instancetype)initWithDevice:(id<MTLDevice>)device
				  textureCache:(CVMetalTextureCacheRef)textureCache
		flutterTextureRegistry:(id<FlutterTextureRegistry>)flutterTextureRegistry
						 width:(NSInteger)width
						height:(NSInteger)height
{
	self = [super init];
	if (self)
	{
		_lock = [[NSLock alloc] init];
		_presenter = [[MetalDrawablePresenterImpl alloc] initWithTextureRegistry:flutterTextureRegistry lock:_lock];
		_metalLayerProvider =
			dgis::dart::map::makeMetalLayerProviderInstance(device, textureCache, _presenter, width, height);
		NSAssert(_metalLayerProvider != nil, @"MetalLayerProvider instance is unavailable");
		_flutterTextureRegistry = flutterTextureRegistry;
	}
	return self;
}

- (CVPixelBufferRef _Nullable)copyPixelBuffer
{
	return [_metalLayerProvider makePixelBuffer];
}

- (void)setMetalTextureToMapWithSurfaceId:(NSInteger)mapSurfaceId
						 flutterTextureId:(NSInteger)textureId
									width:(NSInteger)width
								   height:(NSInteger)height
{
	[_presenter setFlutterTextureId:textureId];
	dgis::dart::map::setMetalTextureToMap(
		mapSurfaceId,
		_metalLayerProvider,
		static_cast<unsigned>(width),
		static_cast<unsigned>(height));
}

- (void)invalidateFlutterTextureId
{
	[_presenter setFlutterTextureId:NSNotFound];
}

@end
