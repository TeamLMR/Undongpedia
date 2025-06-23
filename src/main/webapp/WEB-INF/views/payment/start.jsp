<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<script src="https://nsp.pay.naver.com/sdk/js/naverpay.min.js"></script>

<c:if test="${not empty oPayMap}">
    <script>
        window.onload = () => {
            //mode, clientId, chainId
            var oPay = Naver.Pay.create({
                "mode" : "${oPayMap.mode}", // development or production
                "clientId": "${oPayMap.clientId}", // clientId
                "chainId": "${oPayMap.chainId}", // chainId
            });
            console.log(oPay);
            oPay.open({
                "merchantPayKey":  "${oPayMap.merchantPayKey}",
                "productName": "${oPayMap.productName}",
                "productCount": "${oPayMap.productCount}",
                "totalPayAmount": ${oPayMap.totalPayAmount},
                "taxScopeAmount": ${oPayMap.taxScopeAmount},
                "taxExScopeAmount": ${oPayMap.taxExScopeAmount},
                "returnUrl": "${oPayMap.returnUrl}"
            });
        }
    </script>
</c:if>
<c:if test="${empty oPayment}">
<%--    <script>--%>
<%--        /*여기는 아마 msg나 error로 보내야할 것 같은데..*/--%>
<%--        location.assign("${pageContext.request.contextPath}/cart")--%>
<%--    </script>--%>
</c:if>



