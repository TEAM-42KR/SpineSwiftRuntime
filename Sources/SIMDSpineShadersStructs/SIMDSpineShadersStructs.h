#ifndef SIMDSpineShadersStructs_h
#define SIMDSpineShadersStructs_h

#include <simd/simd.h>

typedef enum SpineVertexInputIndex {
	SpineVertexInputIndexVertices = 0,
	SpineVertexInputIndexTransform = 1,
	SpineVertexInputIndexViewportSize = 2,
} SpineVertexInputIndex;

typedef enum SpineTextureIndex {
	SpineTextureIndexBaseColor = 0,
} SpineTextureIndex;

typedef struct {
	simd_float2 position;
	simd_float2 uv;
	int32_t color;
	int32_t darkColor;
} SpineAdvancedVertex;

typedef struct {
	vector_float2 translation;
	vector_float2 scale;
	vector_float2 offset;
} SpineTransform;

#endif /* SIMDSpineShadersStructs_h */
