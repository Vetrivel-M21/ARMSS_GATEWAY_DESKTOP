/// Config for the ARMSS Gateway backend (separate from the Trust Management
/// backend/`TrustAppClient`) — portal user self-service accounts, per-link
/// access grants, and the Windows installer's OTP gate.
///
/// `adminApiSecret` is extractable from the compiled app's binary, same as
/// `TrustAppClient.clientSecret` — an accepted deterrent against casual
/// direct API access, not a cryptographic boundary. The real gate on the
/// admin screen is the existing local `isAdminOrSuper` check.
class GatewayApiClient {
  GatewayApiClient._();

  static const apiBaseUrl = 'https://armssgateway.arminfo.in/api/v1';
  // static const apiBaseUrl = 'http://localhost:2092/api/v1';
  static const adminApiSecret =
      '277b8823d75d172cb62a9cfa0c9fcd0d6bbdba11895992b7';
  static const installerApiSecret =
      'f46b48cc8a2999302ca05101385eb9219a72878f274b2cd0';
}
