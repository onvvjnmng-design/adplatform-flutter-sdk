# Changelog

## [1.0.4] - 2026-02-10

### Fixed
- Fixed backend API integration compatibility
- Support both `type` and `ad_type` field names
- Support both `click_url` and `target_url` field names
- Support both `cta_text` and `call_to_action` field names
- Support `reward_type`/`reward_amount` as separate fields or `reward` object
- Made `id` dynamic to support both int (production) and string (test ads)
- Made `impression_id` string type to match backend UUID format

## [1.0.3] - 2026-02-10

### Fixed
- Fixed dart analyze errors for pub.dev validation
- Fixed library file naming to match package name
- Fixed imports and exports
- Added missing Reward model properties
- Added ctaText and advertiserName getters to Ad model

## [1.0.2] - 2026-02-10

### Changed
- Updated API base URL to production server (https://adnova.bbs.tr)
- Simplified platform detection logic
- Prepared for pub.dev publication

## [1.0.1] - 2026-02-09

### Fixed
- Minor bug fixes and improvements

## [1.0.0] - 2026-02-09

### Added
- Initial release
- Banner Ads Widget
- Interstitial Ads
- Rewarded Ads with callbacks
- Native Ads
- Ad Listener callbacks (onAdLoaded, onAdFailed, onAdClicked, onAdClosed)
- Reward callbacks for rewarded ads
- Caching support for better performance
- Android and iOS platform support

### Features
- Easy initialization with SDK key
- Customizable banner sizes (320x50, 300x250, 728x90)
- Pre-loading support for interstitial and rewarded ads
- Test mode for development
- Comprehensive error handling

