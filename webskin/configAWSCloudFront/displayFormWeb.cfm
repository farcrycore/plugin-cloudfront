<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin"   prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset oCloudFront = application.fc.lib.cloudfront />

<ft:processform action="Purge URL">
    <cfparam name="FORM.pageRebuild" default="">

    <!--- stripe out protocol and domain --->
    <cfset urlPurgeClean = getURL(Trim(FORM.urlPurge))>
    
    <!--- querystring seems to need dot (regex 'any char') after ? 
    <cfset urlPurgeClean = Replace(urlPurgeClean, '?', '?.')>
    --->
    <!--- querystring - escape + for space --->
    <cfset urlPurgeClean = Replace(urlPurgeClean, '+', '\+')>

    <!--- ensure not trying to delete '/' --->
    <cfif urlPurgeClean == ''>
        <skin:bubble title="Error" message="Enter a valid URL" tags="error" sticky="true" />
    <cfelse>
        <!--- Memcached Purge - rebuild page for each device --->
        <cfloop list="#FORM.pageRebuild#" index="device">
            
            <cfset stResult = pageRebuild(urlPurgeClean, device)>
            <cfif stResult['status_code'] EQ 200>
                <skin:bubble title="Memcached Purged" message="#device#: #urlPurgeClean#"  tags="success" />
                <cfif URL.debug>
                    <cfdump var="#stResult#" label="stResult">
                </cfif>
            <cfelse>
                <cfdump var="#stResult#" label="stResult">
            </cfif>
        </cfloop>			
    
        <!--- ClouldFront Invalidate --->
        <cfset stResult = oCloudFront.invalidatePath(file=urlPurgeClean , distributionName='Web') />
        <cfif URL.debug><cfdump var="#stResult#" label="debug" expand="Yes" abort="No"  /></cfif>
            
        <cfif stResult.success>
            <skin:bubble title="AWS CloudFront" message="#stResult.message#"  tags="success" />
        <cfelse>
            <skin:bubble title="AWS CloudFront" message="URL #urlPurgeClean# has not been purged" tags="error" sticky="true" />
            <cfdump var="#stResult#" label="Error for '#urlPurgeClean#'" expand="Yes" abort="No"  />
        </cfif>
     
    </cfif>

</ft:processform>

<ft:form>
<ft:fieldset legend="Web Page URL">
    <cfoutput>
        <div style="float: right;">
            <p><strong>Enter exact URL or Path with <code>*</code></strong></p>
            <p>Checking Rebuild Page will purge Memcached<br>before invalidating CloudFront.<br>Can not be used with wildcard.</p>
        </div>

        <!---<label>URL: <input name="urlPurge" value="" placeholder="#application.fc.lib.seo.getCanonicalBaseURL()#/images/dmImage/*" style="width: 600px"></label><br />--->
        <label><strong>URL:</strong> <input name="urlPurge" value="" placeholder="/about-us/*" style="width: 600px"></label><br />

        <strong>Rebuild Farcry Page:</strong>
        <label style="display: inline-block;"><input type="checkbox" name="pageRebuild" value="desktop"> Desktop</label>
        <label style="display: inline-block;"><input type="checkbox" name="pageRebuild" value="mobile"> Mobile</label>
    </cfoutput>
    <ft:farcryButtonPanel>
        <ft:button value="Purge URL" type="submit" />
    </ft:farcryButtonPanel>
</ft:fieldset>
</ft:form>


<cffunction name="getURL" returntype="string" output="false" hint="">
	<cfargument name="urlPurge" required="true" type="string">
	
	<cfscript>
	var urlQuery = '';
	var urlPath = '';
	
	    // https://cflib.org/udf/parseUrl
	var sUriRegEx = "^(([^:/?##]+):)?(//([^/?##]*))?([^?##]*)(\?([^##]*))?(##(.*))?";
	
	var stUriInfo = reFindNoCase(sUriRegEx, arguments.urlPurge, 1, true);

	if (stUriInfo.pos.len() >= 6)
		urlPath=mid(arguments.urlPurge,stUriInfo.pos[6],stUriInfo.len[6]);
	
	if (stUriInfo.pos.len() >= 8 AND stUriInfo.len[8] GT 0)
		urlQuery=mid(arguments.urlPurge,stUriInfo.pos[8]-1,stUriInfo.len[8]+1);

	</cfscript>
	
	<cfreturn urlPath & urlQuery>
</cffunction>

<!--- memcached : page Rebuild --->
<cffunction name="pageRebuild" returntype="struct" hint="memcached page rebuild">
    <cfargument name="pageURL" required="true" type="string">
    <cfargument name="device"  required="true" type="string">

    <cfargument name="authUsername"  required="false" type="string" default="">
    <cfargument name="authPassword"  required="false" type="string" default="">
    <cfargument name="timeout"       required="false" type="numeric" default="120">

    <cfset var stResult = {}>
    <cfset var stReturn = {}>
    <cfset var serverURL = "">
    
    <cfset  var CurrentUser = ''>	
    <cftry>	
        <cfset CurrentUser = application.fapi.getCurrentUser().label>
        
        <cfcatch>
            <cfset CurrentUser = "unknown user">
        </cfcatch>
    </cftry>
    
    <cftry>	

        <cfset stReturn['serverURL'] = "#application.fc.lib.seo.getCanonicalProtocol()#://#application.fc.lib.seo.getCanonicalDomain(true)##ARGUMENTS.pageURL#?rebuild=page-#APPLICATION.updateappKey#" >
        <cfset stReturn['device'] = arguments.device>
        <cfhttp
            url="#stReturn['serverURL']#"
            result="stResult"
            timeout="#arguments.timeout#"
            useragent="#arguments.device#"
            username="#arguments.authUsername#"
            password="#arguments.authPassword#"
        />
        <cfset stReturn['status_code'] = stResult['status_code'] >
        <cfif stResult['status_code'] != 200>
            <cflog file="cloudfront" type="error" text="pageRebuild(#ARGUMENTS.pageURL#,#arguments.device#) #serializeJSON(stResult)#">
        </cfif>

        <cfcatch>
            <cfset stReturn['error'] = cfcatch>
            <cflog file="cloudfront" type="error" text="- pageRebuild(#ARGUMENTS.pageURL#,#arguments.device#) #CurrentUser# - #CFCATCH.message# #CFCATCH.detail#  (#arguments.vanishServer# cache)">
        </cfcatch>
    </cftry>

    <cfreturn stReturn>
</cffunction>

<cfsetting enablecfoutputonly="false" />