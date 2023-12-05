Flatbuffers runtime implementation, forked from Google's implementation.

There are several motivations behind this fork:

- this repo is easier to install with `nimble`. The original was nested within the larger `flatbuffers` project, and had improper package structure. This repository is directly linkable and installable with `nimble`, and the package structure has been fixed.

- this fork fixes some bugs in the original implementation. Notably, the original implementation had some issues with some integer types being confused with offset types, leading to malformed flatbuffers and possible security issues.

- Google's Nim implementation is fully undocumented. So is this one! But I do intend to add some documentation in the future.

Currently, this implementation is not in the main `nimble` package repository, however it can still be installed through `nimble` by using the repo's URL directly. This works both when calling `nimble` from the command line as well as from within your project's `*.nimble` file.
