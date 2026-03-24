<cfsetting enablecfoutputonly="true" />

<cfset oCloudFront = application.fc.lib.cloudfront />
<cfset aCdnInvalidations = oCloudFront.getInvalidates(distributionId=URL.distributionId, maxrows=URL.maxrows)>

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
<cfloop array="#aCdnInvalidations#" item="stInvalidation">
    <tr>
        <td>#Replace(stInvalidation.Status, 'InProgress', 'In Progress')#</td>
        <td>#stInvalidation.Path#</td>
        <!--- SDK v2 returns java.time.Instant — convert to java.util.Date for Lucee dateFormat/timeFormat --->
        <cfset createTime = createObject("java", "java.util.Date").from(stInvalidation.CreateTime) />
        <td>#DateFormat(createTime)# #TimeFormat(createTime)#</td>
    </tr>
</cfloop>
</tbody>
</table>
</cfoutput>

<cfsetting enablecfoutputonly="false" />