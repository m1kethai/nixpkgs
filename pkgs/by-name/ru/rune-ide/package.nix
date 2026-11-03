{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  libGL,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  libxkbcommon,
  wayland,
}:

buildGoModule (finalAttrs: {
  pname = "rune-ide";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "unstablebuild";
    repo = "rune";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Q0tlnScblp17/ZL+SwRELYlkk3JKl8J/E06ncq+F06g=";
  };

  # go-tree-sitter keeps its C sources in subdirectories that `go mod vendor`
  # drops, so fetch whole modules through the download cache instead.
  proxyVendor = true;
  vendorHash = "sha256-qj9nImM1VKPZiinmiKp6kWz1r1jg7cC7raMV6p/hUe0=";

  subPackages = [ "cmd/rune" ];

  # The test suites require docker containers and network access, and are
  # only run in upstream's CI (distro builds disable them too).
  doCheck = false;

  tags = [ "ebitensinglethread" ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    libGL
    libx11
    libxcursor
    libxext
    libxi
    libxinerama
    libxrandr
    libxxf86vm
    libxkbcommon
    wayland
  ];

  # Mirrors the production ldflags used by upstream's Debian packaging,
  # minus BuildDate, which would make the build non-reproducible.
  ldflags = [
    "-X unstable.build/rune/internal/debug.Tag=v${finalAttrs.version}"
    "-X unstable.build/rune/internal/debug.Commit=${finalAttrs.src.rev}"
    "-X unstable.build/rune/internal/debug.Package=rune"
    "-X unstable.build/rune/internal/debug.OSPackaged=true"
    "-X unstable.build/rune/cmd/rune/ide/apiclient.DefaultHTTPEndpointAddress=https://api.rune.build"
    "-X unstable.build/rune/cmd/rune/ide/apiclient.DefaultGRPCEndpointAddress=rpc.rune.build:443"
    "-X unstable.build/rune/cmd/rune/ide/apiclient.DefaultDownloadsHost=https://downloads.rune.build"
    "-X unstable.build/rune/cmd/rune/ide/apiclient.DefaultWebsiteAddress=https://rune.build"
  ];

  postInstall = ''
    install -Dm644 deploy/rune-linux/rune.desktop -t $out/share/applications
    install -Dm644 extra/icon.iconset/icon_512x512.png $out/share/icons/hicolor/512x512/apps/rune.png
    install -Dm644 extra/icon.iconset/icon_512x512@2x.png $out/share/icons/hicolor/1024x1024/apps/rune.png
    install -Dm644 dist/debian/rune.1 -t $out/share/man/man1
  '';

  meta = {
    description = "Fast, GPU-accelerated, full-featured IDE and terminal multiplexer";
    homepage = "https://rune.build";
    changelog = "https://github.com/unstablebuild/rune/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ m1kethai ];
    mainProgram = "rune";
    # Only tested on x86_64-linux for now.
    platforms = [ "x86_64-linux" ];
  };
})
