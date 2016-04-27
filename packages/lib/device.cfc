<cfcomponent extends="farcry.core.packages.lib.device" output="false">

	<!--- @@examples:
		<p>Get the device type string from the CloudFront headers, fall back to user agent:</p>
		<code>
			<cfoutput>#application.fc.lib.device.getUserAgentDeviceType()#</cfoutput>
		</code>
	 --->
	<cffunction name="getCloudFrontDeviceType" access="public" output="false" returntype="string" hint="Returns the device type string based on the CloudFront headers, fall back to user agent" bDocument="true">
		<cfargument name="userAgent" type="string" required="false" default="#cgi.user_agent#">

		<cfset var deviceType = "desktop">
		<cfset var stRequestData = getHttpRequestData()>

		<!--- Varnish user agents --->
		<cfif listfindnocase("mobile,tablet,desktop",arguments.userAgent)>
			<cfset deviceType = arguments.userAgent />

		<!--- CloudFront device detection headers --->
		<cfelseif structKeyExists(stRequestData.headers, "CloudFront-Is-Mobile-Viewer") AND stRequestData.headers["CloudFront-Is-Mobile-Viewer"] eq "true">
			<cfif structKeyExists(stRequestData.headers, "CloudFront-Is-Tablet-Viewer") AND stRequestData.headers["CloudFront-Is-Tablet-Viewer"] eq "true">
				<cfset devicetype = "tablet">
			<cfelse>
				<cfset devicetype = "mobile">
			</cfif>
		<cfelseif structKeyExists(stRequestData.headers, "CloudFront-Is-Tablet-Viewer") AND stRequestData.headers["CloudFront-Is-Tablet-Viewer"] eq "true">
			<cfset devicetype = "tablet">
		<cfelseif structKeyExists(stRequestData.headers, "CloudFront-Is-Desktop-Viewer") AND stRequestData.headers["CloudFront-Is-Desktop-Viewer"] eq "true">
			<cfset devicetype = "desktop">

		<!--- iOS Devices --->
		<cfelseif reFindNoCase("(iPod|iPhone)", arguments.userAgent)>
			<cfset deviceType = "mobile">
		<cfelseif reFindNoCase("iPad", arguments.userAgent)>
			<cfset deviceType = "tablet">

		<!--- Android Devices --->
		<cfelseif reFindNoCase("(Android).*(?=Mobile)", arguments.userAgent)>
			<cfset deviceType = "mobile">
		<cfelseif reFindNoCase("Android", arguments.userAgent)>
			<cfset deviceType = "tablet">

		<!--- Windows Phone --->
		<cfelseif reFindNoCase("(Windows Phone).*(?=IEMobile)", arguments.userAgent)>
			<cfset deviceType = "mobile">

		<!--- Other Mobile Devices --->
		<cfelseif reFindNoCase("(Blackberry|webOS|Opera Mini|Opera Mobi)", arguments.userAgent)>
			<cfset deviceType = "mobile">

		</cfif>

		<cfreturn deviceType>
	</cffunction>

	<!--- @@examples:
		<p>Get the device type string:</p>
		<code>
			<cfoutput>#application.fc.lib.device.getDeviceType()#</cfoutput>
		</code>
	 --->
	<cffunction name="getDeviceType" access="public" output="false" returntype="string" hint="Returns the device type string" bDocument="true">

		<cfif NOT structKeyExists(cookie, "FARCRYDEVICETYPE")>
			<cfset setDeviceType(getCloudFrontDeviceType())>
		</cfif>

		<cfreturn cookie.FARCRYDEVICETYPE>
	</cffunction>

</cfcomponent>