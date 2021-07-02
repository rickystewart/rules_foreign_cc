# buildifier: disable=module-docstring
ToolInfo = provider(
    doc = "Information about the native tool",
    fields = {
        "path": (
            "Absolute path to the tool in case the tool is preinstalled on the machine. " +
            "Relative path to the tool in case the tool is built as part of a build; the path should be relative " +
            "to the bazel-genfiles, i.e. it should start with the name of the top directory of the built tree " +
            "artifact. (Please see the example `//examples:built_cmake_toolchain`)"
        ),
        "target": (
            "If the tool is preinstalled, must be None. " +
            "If the tool is built as part of the build, the corresponding build target, which should produce " +
            "the tree artifact with the binary to call."
        ),
    },
)

def _native_tool_toolchain_impl(ctx):
    if not ctx.attr.path and not ctx.attr.target:
        fail("Either path or target (and path) should be defined for the tool.")
    path = None
    if ctx.attr.target:
        path = ctx.expand_location(ctx.attr.path, targets = [ctx.attr.target])
    else:
        path = ctx.expand_location(ctx.attr.path)
    return platform_common.ToolchainInfo(data = ToolInfo(
        path = path,
        target = ctx.attr.target,
    ))

native_tool_toolchain = rule(
    doc = (
        "Rule for defining the toolchain data of the native tools (cmake, ninja), " +
        "to be used by rules_foreign_cc with toolchain types " +
        "`@rules_foreign_cc//toolchains:cmake_toolchain` and " +
        "`@rules_foreign_cc//toolchains:ninja_toolchain`."
    ),
    implementation = _native_tool_toolchain_impl,
    attrs = {
        "path": attr.string(
            mandatory = False,
            doc = (
                "Absolute path to the tool in case the tool is preinstalled on the machine. " +
                "Relative path to the tool in case the tool is built as part of a build; the path should be " +
                "relative to the bazel-genfiles, i.e. it should start with the name of the top directory " +
                "of the built tree artifact. (Please see the example `//examples:built_cmake_toolchain`)"
            ),
        ),
        "target": attr.label(
            mandatory = False,
            cfg = "exec",
            doc = (
                "If the tool is preinstalled, must be None. " +
                "If the tool is built as part of the build, the corresponding build target, " +
                "which should produce the tree artifact with the binary to call."
            ),
        ),
    },
    incompatible_use_toolchain_transition = True,
)
