#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <Metal/Metal.h>
#import <Flutter/Flutter.h>

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

@end
