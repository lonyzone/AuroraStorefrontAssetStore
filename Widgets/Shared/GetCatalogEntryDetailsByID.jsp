<%--
 =================================================================
  Licensed Materials - Property of IBM

  WebSphere Commerce

  (C) Copyright IBM Corp. 2008, 2014 All Rights Reserved.

  US Government Users Restricted Rights - Use, duplication or
  disclosure restricted by GSA ADP Schedule Contract with
  IBM Corp.
 =================================================================
--%>

<!-- BEGIN GetCatalogEntryDetailsByID.jsp -->

<%@ include file="../../Common/EnvironmentSetup.jspf"%>

<wcf:rest var="catalogNavigationView" url="${searchHostNamePath}${searchContextPath}/store/${WCParam.storeId}/productview/byId/${WCParam.catalogEntryId}" >	
			<wcf:param name="langId" value="${langId}"/>
			<wcf:param name="currency" value="${env_currencyCode}"/>
			<wcf:param name="responseFormat" value="json"/>		
			<wcf:param name="catalogId" value="${WCParam.catalogId}"/>
			<c:forEach var="contractId" items="${env_activeContractIds}">
				<wcf:param name="contractId" value="${contractId}"/>
			</c:forEach>
</wcf:rest>

<c:set var="catalogEntry" value="${catalogNavigationView.catalogEntryView[0]}"/>

<%-- catalogIdEntry is used in CatalogEntrySetPriceDisplay.jspf, hence using this variable --%>
<c:set var="catalogIdEntry" value="${catalogEntry}"/>

<%@ include file="../../Snippets/Search/CatalogEntrySetPriceDisplay.jspf" %>
<fmt:formatNumber var="offerPrice" value="${priceString}" type="currency" currencySymbol="${env_CurrencySymbolToFormat}" maxFractionDigits="${env_currencyDecimal}"/>
<c:if test="${not empty listPrice}">
	<fmt:formatNumber var="listPrice" value="${listPrice.value}" type="currency" currencySymbol="${env_CurrencySymbolToFormat}" maxFractionDigits="${env_currencyDecimal}"/>
</c:if>
<c:if test="${not empty calculatedPrice and not empty calculatedPrice.contractIdentifier and not empty calculatedPrice.contractIdentifier.externalIdentifier}">
	<c:set var="ownerID" value="${calculatedPrice.contractIdentifier.externalIdentifier.ownerID}"/>
</c:if>
<c:set var="search" value='"'/>
<c:set var="replaceStr" value='&quot;'/>

<c:set var="catalogEntryId" value="${WCParam.catalogEntryId}"/>
<%@ include file="/Widgets_701/com.ibm.commerce.store.widgets.PDP_Discounts/Discounts_Data.jspf" %>


	<c:choose>
		<c:when test="${empty catalogEntry.thumbnail}">
			<c:set var="thumbNail" value="${jspStoreImgDir}images/NoImageIcon_sm.jpg" />
		</c:when>
		<c:when test="${(fn:startsWith(catalogEntry.thumbnail, 'http://') || fn:startsWith(catalogEntry.thumbnail, 'https://'))}">
			<wcst:resolveContentURL var="thumbNail" url="${catalogEntry.thumbnail}"/>
		</c:when>
		<c:otherwise>
			<c:set var="thumbNail" value="${catalogEntry.thumbnail}" />
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${empty catalogEntry.fullImage}">
			<c:set var="fullImage" value="${jspStoreImgDir}images/NoImageIcon.jpg" />
		</c:when>		
		<c:when test="${(fn:startsWith(catalogEntry.fullImage, 'http://') || fn:startsWith(catalogEntry.fullImage, 'https://'))}">
			<wcst:resolveContentURL var="fullImage" url="${catalogEntry.fullImage}"/>
		</c:when>
		<c:otherwise>
			<c:set var="fullImage" value="${catalogEntry.fullImage}" />
		</c:otherwise>
	</c:choose>

<c:set var="currentContractId" value="${WCParam.curContractId}"/>
<wcbase:useBean id="entitledContracts" classname="com.ibm.commerce.user.beans.ContractListDataBean">
		<c:set target="${entitledContracts}" property="commandContext" value="${CommandContext}"/>
</wcbase:useBean>
<c:set var="numEntitledContracts" value="${fn:length(entitledContracts.contracts)}"/>

<c:if test="${numEntitledContracts == 1 }">
	<c:forEach items="${entitledContracts.contracts}" var="entitledContract">
		<c:if test="${fn:contains(entitledContract.value,'Default Contract')}" >
			<c:set var="defaultContractOnly" value="true"/>
		</c:if>
	</c:forEach >
</c:if>
<%
	String calculatedPriceFlag = (String)(request.getAttribute("calculatedPriceFlag")); 	
%>
<c:set var="count" value="0"/>

/*
{"catalogEntry": {
		"catalogEntryIdentifier": {
			"uniqueID": "${catalogEntry.uniqueID}",
			"externalIdentifier": {
				"partNumber": "${catalogEntry.partNumber}",
				"ownerID": "${ownerID}"
			}
		},
		"description": [{
			"name": "${fn:replace(catalogEntry.name, search, replaceStr)}",
			"thumbnail": "${thumbNail}",
			"fullImage": "${fullImage}",
			"shortDescription": "${fn:replace(catalogEntry.shortDescription, search, replaceStr)}",
			"longDescription": "${fn:replace(catalogEntry.longDescription, search, replaceStr)}",
			"keyword": "${fn:replace(catalogEntry.keyword, search, replaceStr)}",
			"language": "${langId}"
		}],
		"offerPrice": "${offerPrice}",
		"listPrice": "${listPrice}",
		"listPriced": "${not empty listPrice}"
		<c:if test="${not empty calculatedPrice}">
		, "priceRange": [
			<c:forEach var="priceRange" items="${calculatedPrice.priceRange}" varStatus="status">
				<fmt:formatNumber var="localizedPrice" value="${priceRange.value.value}" type="currency" currencySymbol="${env_CurrencySymbolToFormat}" maxFractionDigits="${env_currencyDecimal}"/>
				
				<%-- if maximum quantity is empty need to pass it as null --%>
				<c:choose>
					<c:when test="${empty priceRange.maximumQuantity}">
						<c:set var="maximumQuantity" value="null"/>
					</c:when>
					<c:otherwise>
						<c:set var="maximumQuantity" value="${priceRange.maximumQuantity}"/>
					</c:otherwise>
				</c:choose>
				{
					"startingNumberOfUnits" : "${priceRange.minimumQuantity}",
					"endingNumberOfUnits" : "${maximumQuantity}",
					"localizedPrice" : "${localizedPrice}"
				}<c:if test="${not status.last}">,</c:if>
			</c:forEach>
		]
		</c:if>
		<c:if test="${not empty rangePrice and fn:length(rangePrice)>1}">
		,"priceRange":[
			<c:forEach var="priceRange" items="${rangePrice}" varStatus="var">
				<fmt:formatNumber var="localizedPrice" value="${priceRange.value.value}" type="currency" currencySymbol="${env_CurrencySymbolToFormat}" maxFractionDigits="${env_currencyDecimal}"/>
				<c:choose>
					<c:when test="${empty priceRange.maximumQuantity.value}">
						<c:set var="maximumQuantity" value="null"/>
					</c:when>
					<c:otherwise>
						<c:set var="maximumQuantity" value="${priceRange.maximumQuantity.value}"/>
					</c:otherwise>
				</c:choose>
				{
					"startingNumberOfUnits" : "${priceRange.minimumQuantity.value}",
					"endingNumberOfUnits" : "${maximumQuantity}",
					"localizedPrice" : "${localizedPrice}"
				}<c:if test="${not status.last}">,</c:if>
			</c:forEach>
		]
		</c:if>
		<c:if test="${!empty discounts.calculationCodeDataBeans}" >
		, "discounts" : [
			<c:forEach var="discount" items="${discountsMap}" varStatus="discountCounter">
				{
					"description" : "${discount.key}",
					"url" : "${discount.value}",
				}<c:if test="${not status.last}">,</c:if>
			</c:forEach>
		]
		</c:if>	
		
		 <c:if test="${calculatedPriceFlag == 'true' && defaultContractOnly != 'true'}">
		,"contracts": [
			<c:set var="entitledItem" value="${catalogEntry}"/>
			<%--  Get all the price of the SKU and get the maximum and minimum price. --%>
			
			<c:forEach var="entitledContract" items="${env_activeContractIds}">
				<wcf:rest var="entitledPricesResult" url="/store/{storeId}/price">
					<wcf:var name="storeId" value="${WCParam.storeId}" />
					<wcf:param name="q" value="byCatalogEntryIds"/>
					<wcf:param name="catalogEntryId" value="${entitledItem.uniqueID}" />
					<wcf:param name="currency" value="${env_currencyCode}"/>
					<wcf:param name="contractId" value="${entitledContract}"/>
				</wcf:rest>
				<c:set var="entitledPrices" value="${entitledPricesResult.EntitledPrice}"/>
				<c:remove var="entitledPrice"/>			
				<c:if test="${null!=entitledPrices}">
				    <c:forEach var="entitledPrice" items="${entitledPrices}" varStatus="idx">
					<c:if test="${null != entitledPrice}" >
						<c:if test="${count > 0}">
							,
						</c:if>
						<c:set var="count" value="${count+1}" />	
						{
							<fmt:formatNumber var="contractPrice" value="${entitledPrice.UnitPrice[0].price.value}" type="currency" currencySymbol="${env_CurrencySymbolToFormat}" maxFractionDigits="${env_currencyDecimal}"/>
							"contractId": "<c:out value="${entitledPrice.contractId}"/>",
							<c:remove var="contractDataBean"/>
							<wcbase:useBean id="contractDataBean" classname="com.ibm.commerce.contract.beans.ContractDataBean">
								<c:set target="${contractDataBean}" property="dataBeanKeyReferenceNumber" value="${entitledPrice.contractId}"/>
							</wcbase:useBean>
							"contractName": "<c:out value="${contractDataBean.name}" />",
							"contractPrice": 						
							<c:choose>
								<c:when test="${fn:length(entitledPrice.RangePrice) == 1}">
									"<c:out value="${contractPrice}" />"
								</c:when>
								<c:otherwise>
									[
									<c:set var="contractDisplayPrice" value='"contractDisplayPrice":"${contractPrice}"'/> 	
									<c:forEach var="priceRange" items="${entitledPrice.RangePrice}" varStatus="priceRangeCounter">
										<fmt:formatNumber var="localizedPrice" value="${priceRange.value.value}" type="currency" currencySymbol="${env_CurrencySymbolToFormat}" maxFractionDigits="${env_currencyDecimal}"/>
										{
										<%-- if maximum quantity is empty need to pass it as null --%>
										<c:choose>
											<c:when test="${empty priceRange.maximumQuantity.value}">
												<c:set var="maximumQuantity" value="null"/>
											</c:when>
											<c:otherwise>
												<fmt:parseNumber type="number" integerOnly="true" var="maximumQuantity" value="${priceRange.maximumQuantity.value}" />	
											</c:otherwise>
										</c:choose>
											<fmt:parseNumber type="number" integerOnly="true" var="minimumQuantity" value="${priceRange.minimumQuantity.value}" />
											"startingNumberOfUnits" : "${minimumQuantity}",
											"endingNumberOfUnits" : "${maximumQuantity}",
											"localizedPrice" : "${localizedPrice}"
										}
										<c:if test="${not priceRangeCounter.last}">,</c:if>	
									</c:forEach>
									]						
									,${contractDisplayPrice},"hasPriceRange":"true"
								</c:otherwise>
							</c:choose>			
						}
					</c:if>
				</c:forEach>
			      </c:if>
			</c:forEach>
			
		]
		
		,"numContracts": "${count}"
		,"orderItemId": "${WCParam.orderItemId}"
		,"fromBundlePage":"${param.isBundle}"
		,"currentContractId": "<c:out value="${currentContractId}" />"
		,"isOrderItemADynamicKit": "${catalogEntry.catalogEntryTypeCode eq 'DynamicKitBean'}"
		,"currencySymbol":"${env_CurrencySymbolToFormat}"
		</c:if>		
	}
}
*/

<!-- END GetCatalogEntryDetailsByID.jsp -->