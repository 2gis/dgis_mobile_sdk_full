#import <CoreVideo/CoreVideo.h>
#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

@interface FlutterMetalTexture : NSObject <FlutterTexture>

@property(nonatomic, assign) NSInteger flutterTextureId;
@property(nonatomic, strong) NSLock * lock;

- (instancetype)initWithDevice:(id<MTLDevice>)device
				  textureCache:(CVMetalTextureCacheRef)textureCache
		flutterTextureRegistry:(id<FlutterTextureRegistry>)flutterTextureRegistry
						 width:(NSInteger)width
						height:(NSInteger)height;

- (void)setMetalTextureToMapWithSurfaceId:(NSInteger)mapSurfaceId
						 flutterTextureId:(NSInteger)textureId
									width:(NSInteger)width
								   height:(NSInteger)height;

- (void)invalidateFlutterTextureId;

@end
