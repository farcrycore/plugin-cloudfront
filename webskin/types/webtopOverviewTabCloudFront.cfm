<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!--- @@displayname: CloudFront --->
<!--- @@description: CloudFront Invlaidation for this object  --->
<!--- @@author: Andrew Mercer (andrew@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin"   prefix="skin" />
<cfimport taglib="/farcry/core/tags/navajo"    prefix="nj" />


<cfparam name="FORM.URLs"           default="">
<cfparam name="URL.InvalidationId"  default="">

<!--- TODO: set to WEB ---><cfset distributionName = "CDN">

<cfset urlOverview = "">
<cfloop list="#structKeyList(URL)#" index="key">
	<cfif key NEQ "InvalidationId">
		<cfset urlOverview = ListAppend(urlOverview, '#key#=#url[key]#' , '&')>
	</cfif>
</cfloop>

<cfset oCloudFront = application.fc.lib.cloudfront />

<ft:processform action="Invalidate">

	<cfset URL.InvalidationId = "">
	<cfloop list="#form.urls#" item="urlPurgeClean">
		<!--- ClouldFront Invalidate --->
	    <cfset stResult = oCloudFront.invalidatePath(file=urlPurgeClean, distributionName=distributionName) />
		<cfset URL.InvalidationId = ListAppend(URL.InvalidationId, stResult.InvalidationId)>
	</cfloop>
	
	<cfloop list="#form.urlsOther#"  item="urlPurgeClean" delimiters="#chr(13)#">
		<!--- ClouldFront Invalidate --->
	    <cfset stResult = oCloudFront.invalidatePath(file=urlPurgeClean, distributionName=distributionName) />
		<cfset URL.InvalidationId = ListAppend(URL.InvalidationId, stResult.InvalidationId)>
	</cfloop>

	<cflocation url="/webtop/edittabOverview.cfm?#urlOverview#&InvalidationId=#URL.InvalidationId#">

</ft:processform>


<!------------------ 
START WEBSKIN
 ------------------>

<cfif URL.InvalidationId EQ "">

<!--- friendly URLs for object --->
<cfset qFUCurrent = application.fc.factory.farFU.getFUList(objectid="#stobj.objectid#", fuStatus="current") />


<!--- check for bUseInTree types --->
<cfset objectFU = ''>
<cfif application.fapi.getContentTypeMetadata(typename=stobj.typename, md="bUseInTree", default=false)>
	<!--- look up the parent nav node --->
	<nj:getNavigation objectId="#stobj.objectid#" r_stobject="stNav" />
	<cfset objectFU = application.fapi.getLink(typename="dmNavigation", objectid=stNav.objectID)>
	<cfset onNavNode = true>
<cfelse>
	<cfset onNavNode = false>
</cfif>
		
	<ft:form>	
			<ft:fieldset legend="CloudFront Invalidation">
		
			<ft:fieldsetHelp>
				<cfoutput>
				Select Friendly URLs to invalidate
				</cfoutput>
			</ft:fieldsetHelp>
	
			<ft:field label="Object" bMultiField="false">
				<cfif qFUCurrent.RecordCount>
					<cfloop query="qFUCurrent">
						<cfoutput><label><input type="checkbox" name="urls" value="#qFUCurrent.friendlyurl#"> #qFUCurrent.friendlyurl#</label>						</cfoutput>
					</cfloop>
				<cfelse>
					<cfset friendlyurl = application.fapi.getLink(objectid=stobj.objectid)>
					<cfoutput><label><input type="checkbox" name="urls" value="#friendlyurl#"> #friendlyurl#</cfoutput>
				</cfif>
			</ft:field>
			
			<cfif onNavNode AND stObj.typename NEQ "dmNavigation">
				<ft:field label="Navigation Node" bMultiField="false">
					
					<cfif objectFU NEQ "">
						<cfoutput><label><input type="checkbox" name="urls" value="#objectFU#"> #objectFU#</label>						</cfoutput>
					</cfif>
				</ft:field>
			</cfif>
			
			<ft:field label="Other" bMultiField="false">
				<textarea name="urlsOther" cols="120" rows="5"></textarea> 
				<ft:fieldHint><cfoutput>Enter one URL per line. Use <code>*</code> for wildcard<br />
				eg #application.fapi.getLink(objectid=stobj.objectid)#*</cfoutput></ft:fieldHint>
			</ft:field>
	
			<ft:buttonPanel>
				<ft:button value="Invalidate" />
			</ft:buttonPanel>
		
		</ft:fieldset>
	</ft:form>
<cfelse>
	<!--- get status of invalidations --->
	<cfoutput>
	<table class="farcry-objectadmin table table-striped table-hover">
	<thead>
	    <tr>
	        <th>Status</th>
	        <th>Path</th>
	        <th>Create Time</th>
	    </tr>
	</thead>
	<tbody>
	<cfloop list="#URL.InvalidationId#" index="key">
		<cfset stInvalidation = oCloudFront.getInvalidateById(InvalidationId=key, distributionName=distributionName)>
	    <tr valign="top">
	        <td>#stInvalidation.Status#</td>
	        <td>
		        <cfif Len(stInvalidation.Path) GT 80>
					<cfset pos = find('/', stInvalidation.Path, 60)>
					<cfset stInvalidation.Path = Left(#stInvalidation.Path#,pos) & '<br>' &right(#stInvalidation.Path#, len(stInvalidation.Path)-pos)>
				</cfif>
		        #stInvalidation.Path#
			</td>
	        <td>#TimeFormat(stInvalidation.CreateTime)#</td>
	    </tr>
	</cfloop>
	</tbody>
	</table>
	
	<a href="/webtop/edittabOverview.cfm?#urlOverview#&InvalidationId=#URL.InvalidationId#"><i class="fa fa-refresh"></i> Reload</a>
	</cfoutput>
</cfif>	
		
<cfsetting enablecfoutputonly="false">