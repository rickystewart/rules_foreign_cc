""" Rule for building Ninja from sources. """

load(
    "//foreign_cc/built_tools/private:built_tools_framework.bzl",
    "FOREIGN_CC_BUILT_TOOLS_ATTRS",
    "FOREIGN_CC_BUILT_TOOLS_HOST_FRAGMENTS",
    "built_tool_rule_impl",
)
load("//foreign_cc/private/framework:platform.bzl", "os_name")

def _ninja_tool_impl(ctx):
    script = [
        "./configure.py --bootstrap",
        "mkdir $$INSTALLDIR$$/bin",
        "cp -p ./ninja{} $$INSTALLDIR$$/bin/".format(
            ".exe" if "win" in os_name(ctx) else "",
        ),
    ]

    return built_tool_rule_impl(
        ctx,
        script,
        ctx.actions.declare_directory("ninja"),
        "BootstrapNinjaBuild",
    )

ninja_tool = rule(
    doc = "Rule for building Ninja. Invokes configure script.",
    attrs = FOREIGN_CC_BUILT_TOOLS_ATTRS,
    host_fragments = FOREIGN_CC_BUILT_TOOLS_HOST_FRAGMENTS,
    output_to_genfiles = True,
    implementation = _ninja_tool_impl,
    toolchains = [
        str(Label("//foreign_cc/private/framework:shell_toolchain")),
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
)
