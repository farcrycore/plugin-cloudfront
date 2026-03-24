component displayname="AWS CloudFront Library" {

		public array function getInvalidates(
			string distributionName="",
			string distributionId="",
			number maxrows=20
		) {
			var distributionId = getDistributionId(ARGUMENTS.distributionName, ARGUMENTS.distributionId);
			var cloudFrontService = getClient();

			try {
				var aResults = [];
				var ListInvalidationsRequest = createobject("java","software.amazon.awssdk.services.cloudfront.model.ListInvalidationsRequest")
					.builder()
					.distributionId(distributionId)
					.build();

				var listInvalidationsResponse = cloudFrontService.listInvalidations(ListInvalidationsRequest);
				var aInvalidationList = listInvalidationsResponse.invalidationList().items();

				for (var i in aInvalidationList) {
					var InvalidationRequest = createobject("java","software.amazon.awssdk.services.cloudfront.model.GetInvalidationRequest")
						.builder()
						.id(i.id())
						.distributionId(distributionId)
						.build();

					var Invalidation = cloudFrontService.getInvalidation(InvalidationRequest);

					aResults.append({
						"InvalidationId": i.id(),
						"CreateTime": i.createTime(),
						"Status": i.status(),
						"Path": Invalidation.invalidation().invalidationBatch().paths().items()[1]
					});

					if (aResults.len() == arguments.maxrows) break;
				}

			} catch (any error) {
				dump(var=distributionId, label="listInvalidations: no invalitions for this distribution");
				dump(var=error, label="Error", abort=true);
			}

			return aResults;
		}

	    public struct function invalidatePath(
	    	required string file,
	    	string distributionName="",
			string distributionId="",
	    ) {
	    	var stReturn = {};
			var distributionId = getDistributionId(ARGUMENTS.distributionName, ARGUMENTS.distributionId);

			stReturn['arguments']      = arguments;
			stReturn['distributionId'] = distributionId;

	        var cloudFrontService = getClient();
	        var CallerReference   = CreateUUID();

	        var createInvalidationRequest = createobject("java","software.amazon.awssdk.services.cloudfront.model.CreateInvalidationRequest")
	        	.builder()
	        	.distributionId(distributionId)
	        	.invalidationBatch(
	        		createobject("java","software.amazon.awssdk.services.cloudfront.model.InvalidationBatch")
	        			.builder()
	        			.callerReference(CallerReference)
	        			.paths(
	        				createobject("java","software.amazon.awssdk.services.cloudfront.model.Paths")
	        					.builder()
	        					.items([ arguments.file ])
	        					.quantity(1)
	        					.build()
	        			)
	        			.build()
	        	)
	        	.build();

	        try {
	            var createInvalidationResponse = cloudFrontService.createInvalidation(createInvalidationRequest);

	            stReturn['InvalidationId'] = createInvalidationResponse.invalidation().id();
	            stReturn['Status'] = createInvalidationResponse.invalidation().status();

	            stReturn['CallerReference'] = CallerReference;
	            stReturn['success'] = true;
	            stReturn['message'] = "Submitted to CloudFront";
	        }
	        catch (software.amazon.awssdk.services.cloudfront.model.TooManyInvalidationsInProgressException error){
	            stReturn['error']   = error;
	            stReturn['success'] = false;
	            stReturn['message'] = "Too Many Invalidations In Progress";
	        }
	        catch (any error) {
	        	stReturn['error']   = error;
	        	stReturn['success'] = false;
	        	stReturn['message'] = "#error.Message#. #error.Detail#";
	        }

	        return stReturn;
	    }

		public struct function getDistributions(){

			var stDistributions = {};
			var stDistribution = {};
			var aOrigins       = [];
			var stOrigin       = {};

			var cloudFrontService = getClient();

			var ListDistributionsRequest = createobject("java","software.amazon.awssdk.services.cloudfront.model.ListDistributionsRequest")
				.builder()
				.build();
			var ListDistributionsResult = cloudFrontService.listDistributions(ListDistributionsRequest);
			var aDistributions = ListDistributionsResult.distributionList().items();

			for (stDistribution in aDistributions) {

				stDistributions[stDistribution.id()] = {};
				stDistributions[stDistribution.id()]['DomainName'] = stDistribution.domainName();
				stDistributions[stDistribution.id()]['OriginDomainNames'] = '';

				aOrigins = stDistribution.origins().items();
				for (stOrigin in aOrigins) {
					stDistributions[stDistribution.id()]['OriginDomainNames'] = ListAppend(stDistributions[stDistribution.id()]['OriginDomainNames'], stOrigin.domainName());
				}
			}

			return stDistributions;

		}

	public struct function getInvalidateById(
		required string InvalidationId,
		string distributionName="",
		string distributionId="",
	) {
			var status = '#arguments.InvalidationId# not found';
			var distributionId = getDistributionId(ARGUMENTS.distributionName, ARGUMENTS.distributionId);

		try {
			var cloudFrontService = getClient();

			var InvalidationRequest = createobject("java","software.amazon.awssdk.services.cloudfront.model.GetInvalidationRequest")
				.builder()
				.id(arguments.InvalidationId)
				.distributionId(distributionId)
				.build();

			var invalidation = cloudFrontService.getInvalidation(InvalidationRequest);
			var i = invalidation.invalidation();
			var stResult = {
				"InvalidationId": i.id(),
				"CreateTime": i.createTime(),
				"Status": i.status(),
				"Path": i.invalidationBatch().paths().items()[1]
			};


		} catch (any error) {
			dump(var=arguments, label="getInvalidateStatus: no invalitions for this distribution");
			dump(var=error, label="Error", abort=true);
		}

		return stResult;
	}


    private any function getClient(){
		var accessID  = application.fapi.getConfig('awscloudfront','accessID');
		var secretKey = application.fapi.getConfig('awscloudfront','secretKey');
		var regionName  = application.fapi.getConfig('awscloudfront','region', 'us-east-1');

		if (len(accessID) AND len(secretKey)) {
			writeLog(file="cloudfront", text="getClient: using StaticCredentialsProvider (FarCry config awscloudfront.accessID/secretKey)");
			var credentials = createobject("java","software.amazon.awssdk.auth.credentials.AwsBasicCredentials").create(accessID, secretKey);
			var credentialsProvider = createobject("java","software.amazon.awssdk.auth.credentials.StaticCredentialsProvider").create(credentials);
		} else {
			writeLog(file="cloudfront", text="getClient: using DefaultCredentialsProvider (IAM role / env vars / credentials chain)");
			var credentialsProvider = createobject("java","software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider").create();
		}

		var region = createobject("java","software.amazon.awssdk.regions.Region").of(regionName);
		var CloudFrontClient = createobject("java","software.amazon.awssdk.services.cloudfront.CloudFrontClient")
			.builder()
			.region(region)
			.credentialsProvider(credentialsProvider)
			.build();

		return CloudFrontClient;
    }

	private string function getDistributionId(
		string distributionName="",
		string distributionId=""
	) {

		if (ARGUMENTS.distributionId != '')
			distributionId = ARGUMENTS.distributionId;
		else if (ARGUMENTS.distributionName == 'WEB') {
			distributionId = application.fapi.getConfig('awscloudfront','wwwDistributionId', '');
			if (distributionId == "") {
				throw(type='cloudfront.getDistributionId.wwwDistributionId', message="WWW Distribution Id has not been set", detail="Set value in Configuration 'AWS CloudFront Service' ");
			}
		} else if (ARGUMENTS.distributionName == 'CDN') {
			distributionId = application.fapi.getConfig('awscloudfront','cdnDistributionId', '');
			if (distributionId == "") {
				throw(type='cloudfront.getDistributionId.cdnDistributionId', message="CDN Distribution Id has not been set", detail="Set value in Configuration 'AWS CloudFront Service' ");
			}
		} else {
			throw(type='cloudfront.getDistributionId.distribution', message="Distribution must be Distibution ID or Name [WEB|CDN]", detail="distributionId='#ARGUMENTS.distribution#'. distributionName='#ARGUMENTS.distributionName#'");
		}
		return distributionId;

	}
}