# Programming Project 3: OTP

## Description

This is a CLI tool built with Elixir that generates QR and OTP codes for use with Google Authenticator. This app generates an SVG QR code of the otpauth:// URI from the generated secret, issuer, and account name.

## Dependencies

- [Elixir ~> 1.18](https://elixir-lang.org/install.html)
- [Erlang/OTP 28](https://www.erlang.org/downloads)

>[!IMPORTANT]
> Before trying to compile from source, make sure you have
> `Elixir` and the `Erlang/OTP BEAM VM` installed.

## Installation on Linux & Mac

To compile and build the project, run:

```bash
make build
```

This will generate an executable in the root directory named `otp`.

> [!NOTE]
> When compiling the project, you may see this warning:
>
> ```text
>   warning: List.zip/1 is deprecated. Use Enum.zip/1 instead
>    └─ lib/matrix_reloaded/vector.ex:...
> ```
> 
> This comes from a third-party dependency, **does not** affect application functionality, and can be safely ignored.

### Using the app

```bash
# To view available commands
./otp
```

```bash
# To generate a QR code
./otp --generate-qr
```

```bash
# To generate OTP code
./otp --get-otp
```

## Windows Specific Instructions

To execute the compiled binary on Windows, preface commands with: `escript`.
(Either in Powershell or cmd)

### Using the app

```bash
# To view available commands
escript ./otp
```

```bash
# To generate a QR code
escript ./otp --generate-qr
```

```bash
# To generate OTP code
escript ./otp --get-otp
```

> [!IMPORTANT]
> This application supports automatically opening the QR code for display,
> however this feature has only been implemented for:
>
> - Most Linux systems (via `xdg-open`)
> - macOS
>
> If this application does not automatically open the QR code, it can be located
> in the root directory named `qr_code.svg`.

## Documentation

Documentation is automatically generated from function and module docs thanks to `ex_doc`!

To generate the docs:

```bash
make docs
```

To view the docs:
```bash
cd doc

# Spin up simple HTTP server (does not need to be python3 http.server)
python3 -m http.server
```

Then visit [https://localhost:8000](https://localhost:8000) in a web-browser to view the docs.

## Implementation Details
This app generates an otpauth:// URI from a secret key, issuer, and account name. The URI is fed to the Elixir library `QRCode v3.2.0` to generate a QR code which is saved as `qr_code.svg`. This implementation adheres to RFC 6238 and supports use with Google Authenticator.
