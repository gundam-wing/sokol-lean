#pragma once

#include <lean/lean.h>
#include <string.h>

#include "sokol_app.h"
#include "sokol_gfx.h"
#include "sokol_glue.h"
#include "sokol_log.h"
#include "sokol_time.h"

static inline lean_obj_res sokol_lean_ok_unit(void) {
  return lean_io_result_mk_ok(lean_box(0));
}

static inline lean_obj_res sokol_lean_ok_u32(uint32_t x) {
  return lean_io_result_mk_ok(lean_box_uint32(x));
}

static inline lean_obj_res sokol_lean_ok_u64(uint64_t x) {
  return lean_io_result_mk_ok(lean_box_uint64(x));
}

static inline lean_obj_res sokol_lean_ok_bool(bool x) {
  return lean_io_result_mk_ok(lean_box(x ? 1 : 0));
}

static inline uint32_t sokol_lean_unbox_u32(b_lean_obj_arg o) {
  return lean_unbox_uint32(o);
}

static inline void sokol_lean_run_io(lean_object* fn) {
  lean_inc(fn);
  lean_object* r = lean_apply_1(fn, lean_io_mk_world());
  if (lean_io_result_is_error(r)) {
    lean_io_result_show_error(r);
  }
  lean_dec(r);
}
