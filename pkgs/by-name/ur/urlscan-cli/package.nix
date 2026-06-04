{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "urlscan-cli";
  version = "2026.03.26";

  src = fetchFromGitHub {
    owner = "urlscan";
    repo = "urlscan-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  ldflags = [
    "-s"
    "-w"
    "-X github.com/urlscan/urlscan-cli/pkg/version.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Official urlscan.io and urlscan Pro CLI";
    homepage = "https://github.com/urlscan/urlscan-cli";
    changelog = "https://github.com/urlscan/urlscan-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "urlscan";
  };
})
