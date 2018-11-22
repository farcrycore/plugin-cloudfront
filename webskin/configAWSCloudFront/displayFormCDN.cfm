<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin"   prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />


<cfset oCloudFront = application.fc.lib.cloudfront />

<ft:processform action="Purge URL">
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
        
        <cfset stResult = oCloudFront.invalidatePath(file=urlPurgeClean , distributionName='CDN') />
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
<ft:fieldset legend="CDN Assets URL">
    <cfoutput>
        <div style="float: right;">
            <p><strong>Enter exact URL or Path with <code>*</code></strong></p>
        </div>

        <!---<label>URL: <input name="urlPurge" value="" placeholder="#application.fc.lib.seo.getCanonicalBaseURL()#/images/dmImage/*" style="width: 600px"></label><br />--->
        <label>URL: <input name="urlPurge" value="" placeholder="/images/dmImage/*" style="width: 600px"></label><br />
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

<cfsetting enablecfoutputonly="false" />