#ifndef SPINE_C_ARRAYS_H
#define SPINE_C_ARRAYS_H

#include "spine-cpp-lite.h"
#include <spine_apple_extension/arrays.h>
#include <spine_apple_extension/atlas_page.h>
#include <stdbool.h>
#include <stddef.h>

SPINE_OPAQUE_TYPE(spine_array_atlas_page)

#ifdef __cplusplus
extern "C" {
#endif

#define SPINE_C_API SPINE_CPP_LITE_EXPORT

SPINE_C_API spine_array_atlas_page spine_array_atlas_page_create(void);

SPINE_C_API spine_array_atlas_page spine_array_atlas_page_create_with_capacity(size_t initialCapacity);
SPINE_C_API void spine_array_atlas_page_dispose(spine_array_atlas_page array);
SPINE_C_API void spine_array_atlas_page_clear(spine_array_atlas_page array);

SPINE_C_API size_t spine_array_atlas_page_get_capacity(spine_array_atlas_page array);

SPINE_C_API size_t spine_array_atlas_page_size(spine_array_atlas_page array);

SPINE_C_API spine_array_atlas_page spine_array_atlas_page_set_size(spine_array_atlas_page array, size_t newSize, spine_atlas_page defaultValue);

SPINE_C_API void spine_array_atlas_page_ensure_capacity(spine_array_atlas_page array, size_t newCapacity);

SPINE_C_API void spine_array_atlas_page_add(spine_array_atlas_page array, spine_atlas_page inValue);

SPINE_C_API void spine_array_atlas_page_add_all(spine_array_atlas_page array, spine_array_atlas_page inValue);

SPINE_C_API void spine_array_atlas_page_clear_and_add_all(spine_array_atlas_page array, spine_array_atlas_page inValue);

SPINE_C_API void spine_array_atlas_page_remove_at(spine_array_atlas_page array, size_t inIndex);

SPINE_C_API bool spine_array_atlas_page_contains(spine_array_atlas_page array, spine_atlas_page inValue);

SPINE_C_API int spine_array_atlas_page_index_of(spine_array_atlas_page array, spine_atlas_page inValue);

SPINE_C_API spine_atlas_page *spine_array_atlas_page_buffer(spine_array_atlas_page array);

#ifdef __cplusplus
}
#endif

#endif /* SPINE_C_ARRAYS_H */
