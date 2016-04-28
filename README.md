# Amazon CloudFront plugin for FarCry Core 7.x

This plugin will add support for device detection using [CloudFront device type headers](http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/header-caching.html#header-caching-web-device).
Support for other CloudFront features may be added in the future.

## Installation

- extract the plugin to `/farcry/plugins/cloudfront`
- register the plugin in your `farcryContructor.cfm`
- configure your CloudFront distribution to support device type detection

## Configure CloudFront

CloudFront Distribution configurations will vary based on your app's specific requirements.  We provide some common configuration strategies for reference.

### Mobile Templates

If you have an adaptive layout strategy of providing distinct templates for say desktop and mobile you will need to make some specific configuraiton changes to allow FarCry to switch on device type.

1. Configure CloudFront to cache objects based on the CloudFront device type headers

 ![Whitelist device type headers](docs/cf-whitelist-headers.jpg)

2. Add the cookie name `FARCRYDEVICETYPE` to the whitelist of forwarded cookies

 ![Whitelist cookies](docs/cf-whitelist-cookies.jpg)
