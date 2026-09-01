#include "sokol_lean.h"

#include <stdint.h>
#include <stdlib.h>

#if defined(__APPLE__)
/*
 * Lean 4's `lean_run_main` hops onto a worker thread (`LEAN_MAIN_USE_THREAD`).
 * AppKit will not create a window there; `[NSApp run]` just throws in a tight loop.
 * This must be set before `main` so `getenv` sees it.
 */
__attribute__((constructor))
static void sokol_lean_macos_main_thread(void) {
  setenv("LEAN_MAIN_USE_THREAD", "0", 1);
}
#endif

/* -------------------------------------------------------------------------- */
/* Time                                                                        */
/* -------------------------------------------------------------------------- */

lean_obj_res lean_stm_setup(lean_obj_arg world) {
  (void)world;
  stm_setup();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_stm_now(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u64(stm_now());
}

double lean_stm_sec(uint64_t ticks) {
  return stm_sec(ticks);
}

double lean_stm_ms(uint64_t ticks) {
  return stm_ms(ticks);
}

lean_obj_res lean_stm_diff(uint64_t new_ticks, uint64_t old_ticks, lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u64(stm_diff(new_ticks, old_ticks));
}

lean_obj_res lean_stm_since(uint64_t start, lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u64(stm_since(start));
}

/* -------------------------------------------------------------------------- */
/* App                                                                         */
/* -------------------------------------------------------------------------- */

static lean_object* g_init_cb = NULL;
static lean_object* g_frame_cb = NULL;
static lean_object* g_cleanup_cb = NULL;
static lean_object* g_event_cb = NULL;

static void sokol_lean_keep(lean_object** slot, b_lean_obj_arg neu) {
  if (*slot) {
    lean_dec(*slot);
  }
  *slot = neu;
  lean_inc(neu);
}

static void sokol_lean_drop_cbs(void) {
  if (g_init_cb) { lean_dec(g_init_cb); g_init_cb = NULL; }
  if (g_frame_cb) { lean_dec(g_frame_cb); g_frame_cb = NULL; }
  if (g_cleanup_cb) { lean_dec(g_cleanup_cb); g_cleanup_cb = NULL; }
  if (g_event_cb) { lean_dec(g_event_cb); g_event_cb = NULL; }
}

static void sokol_lean_init_cb(void) {
  if (g_init_cb) sokol_lean_run_io(g_init_cb);
}

static void sokol_lean_frame_cb(void) {
  if (g_frame_cb) sokol_lean_run_io(g_frame_cb);
}

static void sokol_lean_cleanup_cb(void) {
  if (g_cleanup_cb) sokol_lean_run_io(g_cleanup_cb);
  sokol_lean_drop_cbs();
}

static void sokol_lean_event_cb(const sapp_event* ev) {
  if (!g_event_cb) return;
  lean_inc(g_event_cb);
  lean_object* r = lean_apply_2(
    g_event_cb,
    lean_box_usize((size_t)ev),
    lean_io_mk_world());
  if (lean_io_result_is_error(r)) {
    lean_io_result_show_error(r);
  }
  lean_dec(r);
}

lean_obj_res lean_sapp_run(
    uint32_t width,
    uint32_t height,
    uint32_t sample_count,
    uint8_t high_dpi,
    b_lean_obj_arg title,
    b_lean_obj_arg init_cb,
    b_lean_obj_arg frame_cb,
    b_lean_obj_arg cleanup_cb,
    b_lean_obj_arg event_cb,
    lean_obj_arg world) {
  (void)world;
  sokol_lean_keep(&g_init_cb, init_cb);
  sokol_lean_keep(&g_frame_cb, frame_cb);
  sokol_lean_keep(&g_cleanup_cb, cleanup_cb);
  sokol_lean_keep(&g_event_cb, event_cb);

  const char* title_cstr = lean_string_cstr(title);
  sapp_desc desc;
  memset(&desc, 0, sizeof(desc));
  desc.width = (int)width;
  desc.height = (int)height;
  desc.sample_count = (int)sample_count;
  desc.high_dpi = high_dpi != 0;
  desc.window_title = title_cstr;
  desc.init_cb = sokol_lean_init_cb;
  desc.frame_cb = sokol_lean_frame_cb;
  desc.cleanup_cb = sokol_lean_cleanup_cb;
  desc.event_cb = sokol_lean_event_cb;
  desc.logger.func = slog_func;
  desc.icon.sokol_default = true;
  sapp_run(&desc);
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sapp_isvalid(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_bool(sapp_isvalid());
}

lean_obj_res lean_sapp_width(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u32((uint32_t)sapp_width());
}

lean_obj_res lean_sapp_height(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u32((uint32_t)sapp_height());
}

lean_obj_res lean_sapp_widthf(lean_obj_arg world) {
  (void)world;
  return lean_io_result_mk_ok(lean_box_float((double)sapp_widthf()));
}

lean_obj_res lean_sapp_heightf(lean_obj_arg world) {
  (void)world;
  return lean_io_result_mk_ok(lean_box_float((double)sapp_heightf()));
}

lean_obj_res lean_sapp_dpi_scale(lean_obj_arg world) {
  (void)world;
  return lean_io_result_mk_ok(lean_box_float((double)sapp_dpi_scale()));
}

lean_obj_res lean_sapp_frame_count(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u64(sapp_frame_count());
}

lean_obj_res lean_sapp_frame_duration(lean_obj_arg world) {
  (void)world;
  return lean_io_result_mk_ok(lean_box_float(sapp_frame_duration()));
}

lean_obj_res lean_sapp_request_quit(lean_obj_arg world) {
  (void)world;
  sapp_request_quit();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sapp_quit(lean_obj_arg world) {
  (void)world;
  sapp_quit();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sapp_set_window_title(b_lean_obj_arg title, lean_obj_arg world) {
  (void)world;
  sapp_set_window_title(lean_string_cstr(title));
  return sokol_lean_ok_unit();
}

uint32_t lean_sapp_event_type(size_t ev) {
  return (uint32_t)((const sapp_event*)ev)->type;
}

uint32_t lean_sapp_event_keycode(size_t ev) {
  return (uint32_t)((const sapp_event*)ev)->key_code;
}

uint32_t lean_sapp_event_char_code(size_t ev) {
  return ((const sapp_event*)ev)->char_code;
}

uint8_t lean_sapp_event_key_repeat(size_t ev) {
  return ((const sapp_event*)ev)->key_repeat ? 1 : 0;
}

uint32_t lean_sapp_event_modifiers(size_t ev) {
  return ((const sapp_event*)ev)->modifiers;
}

uint32_t lean_sapp_event_mouse_button(size_t ev) {
  return (uint32_t)((const sapp_event*)ev)->mouse_button;
}

double lean_sapp_event_mouse_x(size_t ev) {
  return (double)((const sapp_event*)ev)->mouse_x;
}

double lean_sapp_event_mouse_y(size_t ev) {
  return (double)((const sapp_event*)ev)->mouse_y;
}

double lean_sapp_event_mouse_dx(size_t ev) {
  return (double)((const sapp_event*)ev)->mouse_dx;
}

double lean_sapp_event_mouse_dy(size_t ev) {
  return (double)((const sapp_event*)ev)->mouse_dy;
}

double lean_sapp_event_scroll_x(size_t ev) {
  return (double)((const sapp_event*)ev)->scroll_x;
}

double lean_sapp_event_scroll_y(size_t ev) {
  return (double)((const sapp_event*)ev)->scroll_y;
}

uint32_t lean_sapp_event_window_width(size_t ev) {
  return (uint32_t)((const sapp_event*)ev)->window_width;
}

uint32_t lean_sapp_event_window_height(size_t ev) {
  return (uint32_t)((const sapp_event*)ev)->window_height;
}

uint64_t lean_sapp_event_frame_count(size_t ev) {
  return ((const sapp_event*)ev)->frame_count;
}

/* -------------------------------------------------------------------------- */
/* Gfx                                                                         */
/* -------------------------------------------------------------------------- */

lean_obj_res lean_sokol_pack_f32(b_lean_obj_arg xs) {
  size_t n = lean_array_size(xs);
  size_t nbytes = n * 4;
  lean_object* ba = lean_alloc_sarray(1, nbytes, nbytes);
  uint8_t* dst = (uint8_t*)lean_sarray_cptr(ba);
  for (size_t i = 0; i < n; i++) {
    double d = lean_unbox_float(lean_array_uget(xs, i));
    float f = (float)d;
    memcpy(dst + i * 4, &f, 4);
  }
  return ba;
}

lean_obj_res lean_sg_setup(lean_obj_arg world) {
  (void)world;
  sg_setup(&(sg_desc){
    .environment = sglue_environment(),
    .logger.func = slog_func,
  });
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_setup_headless(lean_obj_arg world) {
  (void)world;
  sg_setup(&(sg_desc){
    .logger.func = slog_func,
  });
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_shutdown(lean_obj_arg world) {
  (void)world;
  sg_shutdown();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_isvalid(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_bool(sg_isvalid());
}

lean_obj_res lean_sg_query_backend(lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u32((uint32_t)sg_query_backend());
}

lean_obj_res lean_sg_reset_state_cache(lean_obj_arg world) {
  (void)world;
  sg_reset_state_cache();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_make_buffer(
    b_lean_obj_arg data,
    uint8_t index,
    uint8_t stream,
    lean_obj_arg world) {
  (void)world;
  sg_buffer_desc d;
  memset(&d, 0, sizeof(d));
  size_t n = lean_sarray_size(data);
  d.data.ptr = n ? lean_sarray_cptr(data) : NULL;
  d.data.size = n;
  if (index) {
    d.usage.index_buffer = true;
    d.usage.vertex_buffer = false;
  }
  if (stream) {
    d.usage.stream_update = true;
    d.usage.immutable = false;
  }
  sg_buffer buf = sg_make_buffer(&d);
  return sokol_lean_ok_u32(buf.id);
}

lean_obj_res lean_sg_make_buffer_size(
    size_t size,
    uint8_t index,
    uint8_t stream,
    lean_obj_arg world) {
  (void)world;
  sg_buffer_desc d;
  memset(&d, 0, sizeof(d));
  d.size = size;
  if (index) {
    d.usage.index_buffer = true;
    d.usage.vertex_buffer = false;
  }
  if (stream) {
    d.usage.stream_update = true;
    d.usage.immutable = false;
  }
  sg_buffer buf = sg_make_buffer(&d);
  return sokol_lean_ok_u32(buf.id);
}

lean_obj_res lean_sg_destroy_buffer(uint32_t id, lean_obj_arg world) {
  (void)world;
  sg_destroy_buffer((sg_buffer){ .id = id });
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_update_buffer(uint32_t id, b_lean_obj_arg data, lean_obj_arg world) {
  (void)world;
  sg_range rng = { .ptr = lean_sarray_cptr(data), .size = lean_sarray_size(data) };
  sg_update_buffer((sg_buffer){ .id = id }, &rng);
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_query_buffer_state(uint32_t id, lean_obj_arg world) {
  (void)world;
  return sokol_lean_ok_u32((uint32_t)sg_query_buffer_state((sg_buffer){ .id = id }));
}

lean_obj_res lean_sg_make_shader(
    b_lean_obj_arg vs,
    b_lean_obj_arg fs,
    b_lean_obj_arg attrs,
    lean_obj_arg world) {
  (void)world;
  sg_shader_desc d;
  memset(&d, 0, sizeof(d));
  d.vertex_func.source = lean_string_cstr(vs);
  d.fragment_func.source = lean_string_cstr(fs);
  size_t n = lean_array_size(attrs);
  if (n > SG_MAX_VERTEX_ATTRIBUTES) n = SG_MAX_VERTEX_ATTRIBUTES;
  for (size_t i = 0; i < n; i++) {
    d.attrs[i].glsl_name = lean_string_cstr(lean_array_uget(attrs, i));
  }
  sg_shader shd = sg_make_shader(&d);
  return sokol_lean_ok_u32(shd.id);
}

lean_obj_res lean_sg_destroy_shader(uint32_t id, lean_obj_arg world) {
  (void)world;
  sg_destroy_shader((sg_shader){ .id = id });
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_make_pipeline(
    uint32_t shader_id,
    b_lean_obj_arg formats,
    uint32_t primitive,
    uint32_t index_type,
    lean_obj_arg world) {
  (void)world;
  sg_pipeline_desc d;
  memset(&d, 0, sizeof(d));
  d.shader.id = shader_id;
  d.primitive_type = (sg_primitive_type)primitive;
  d.index_type = (sg_index_type)index_type;
  size_t n = lean_array_size(formats);
  if (n > SG_MAX_VERTEX_ATTRIBUTES) n = SG_MAX_VERTEX_ATTRIBUTES;
  for (size_t i = 0; i < n; i++) {
    d.layout.attrs[i].format = (sg_vertex_format)sokol_lean_unbox_u32(lean_array_uget(formats, i));
  }
  sg_pipeline pip = sg_make_pipeline(&d);
  return sokol_lean_ok_u32(pip.id);
}

lean_obj_res lean_sg_destroy_pipeline(uint32_t id, lean_obj_arg world) {
  (void)world;
  sg_destroy_pipeline((sg_pipeline){ .id = id });
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_begin_swapchain_pass(
    double r, double g, double b, double a,
    lean_obj_arg world) {
  (void)world;
  sg_pass pass = {
    .action = {
      .colors[0] = {
        .load_action = SG_LOADACTION_CLEAR,
        .clear_value = { (float)r, (float)g, (float)b, (float)a },
      }
    },
    .swapchain = sglue_swapchain(),
  };
  sg_begin_pass(&pass);
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_end_pass(lean_obj_arg world) {
  (void)world;
  sg_end_pass();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_commit(lean_obj_arg world) {
  (void)world;
  sg_commit();
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_apply_pipeline(uint32_t id, lean_obj_arg world) {
  (void)world;
  sg_apply_pipeline((sg_pipeline){ .id = id });
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_apply_bindings(
    b_lean_obj_arg vbufs,
    uint32_t ibuf,
    lean_obj_arg world) {
  (void)world;
  sg_bindings b;
  memset(&b, 0, sizeof(b));
  size_t n = lean_array_size(vbufs);
  if (n > SG_MAX_VERTEXBUFFER_BINDSLOTS) n = SG_MAX_VERTEXBUFFER_BINDSLOTS;
  for (size_t i = 0; i < n; i++) {
    b.vertex_buffers[i].id = sokol_lean_unbox_u32(lean_array_uget(vbufs, i));
  }
  b.index_buffer.id = ibuf;
  sg_apply_bindings(&b);
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_apply_uniforms(uint32_t slot, b_lean_obj_arg data, lean_obj_arg world) {
  (void)world;
  sg_range rng = { .ptr = lean_sarray_cptr(data), .size = lean_sarray_size(data) };
  sg_apply_uniforms((int)slot, &rng);
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_draw(uint32_t base, uint32_t n, uint32_t instances, lean_obj_arg world) {
  (void)world;
  sg_draw((int)base, (int)n, (int)instances);
  return sokol_lean_ok_unit();
}

lean_obj_res lean_sg_apply_viewport(
    uint32_t x, uint32_t y, uint32_t w, uint32_t h,
    uint8_t origin_top_left,
    lean_obj_arg world) {
  (void)world;
  sg_apply_viewport((int)x, (int)y, (int)w, (int)h, origin_top_left != 0);
  return sokol_lean_ok_unit();
}
