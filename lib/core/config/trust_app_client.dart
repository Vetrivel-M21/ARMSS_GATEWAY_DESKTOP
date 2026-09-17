/// Pre-registered device identity for the Trust Management backend's
/// `/api/v1/device/auth` endpoint — proves requests from this app's Trust
/// Portal tab originate from the desktop client, not a plain browser.
///
/// The secret is extractable from the compiled app's binary (no different
/// from any embedded API key) — this is an accepted deterrent against casual/
/// direct browser access, not a cryptographic boundary against a determined
/// reverse-engineer.
class TrustAppClient {
  TrustAppClient._();

  static const clientId = 'b1880c9d-0792-47fc-8200-8d1d2d74c96c';
  static const clientSecret = '625456a6f1033e996aa558a1b706961e4513c86915f921207ce031a91bf3f782';
  static const apiBaseUrl = 'https://trustapi.arminfo.in/api/v1';
  static const portalUrl = 'http://localhost:5173/';
}
