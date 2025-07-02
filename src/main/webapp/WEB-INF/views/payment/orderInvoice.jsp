<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>거래명세서</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/html2canvas@1.4.1/dist/html2canvas.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            font-size: 14px;
            background-color: #f8f9fa;
        }
        .invoice-container {
            width: 900px;
            margin: 0 auto;
            padding: 40px;
            background-color: white;
            color: black;
            border: 1px solid #ccc;
        }
        .invoice-title {
            font-size: 28px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 30px;
        }
        .section-title {
            font-weight: bold;
            margin-top: 20px;
            margin-bottom: 10px;
            border-bottom: 2px solid #212529;
            padding-bottom: 5px;
        }
        table.invoice-table {
            width: 100%;
            border-collapse: collapse;
        }
        .invoice-table th, .invoice-table td {
            border: 1px solid #000;
            padding: 10px;
            text-align: center;
        }
        .summary td {
            font-weight: bold;
        }
    </style>
</head>
<body>

<div class="invoice-container" id="invoice">
    <!-- 제목 -->
    <div class="invoice-title">거래명세서</div>

    <!-- 주문 정보 -->
    <div class="d-flex justify-content-between mb-4">
        <div>거래일자: <fmt:formatDate value="${ordersList[0].ordersTimestamp}" pattern="yyyy.MM.dd" /></div>
        <div>주문번호: ${ordersList[0].detail.ordersPaymentId}</div>
    </div>

    <!-- 공급자 정보 -->
    <div class="mb-4 border-black border-bottom border-2">
        <div class="section-title">공급자</div>
        <div>사업자등록번호: 123-45-67890</div>
        <div>상호: 운동백과</div>
        <div>대표자: 한창규</div>
        <div>소재지: 서울특별시 금천구 벚꽃로266</div>
        <div class="mb-2">업태: 서비스 / 종목: 온라인 교육</div>
    </div>

    <!-- 품목 테이블 -->
    <table class="invoice-table mb-4">
        <thead>
        <tr>
            <th>품명</th>
            <th>수량</th>
            <th>단가</th>
            <th>공급가액</th>
            <th>세액</th>
            <th>비고</th>
        </tr>
        </thead>
        <tbody>
        <c:if test="${ordersList[0].ordersStatus eq 'CANC'}">
            <c:set var="colorClass"  value="bg-danger-subtle"/>
            <c:set var="bigoText"  value="환불 완료"/>
        </c:if>
        <c:if test="${ordersList[0].ordersStatus eq 'PAID'}">
            <c:set var="colorClass"  value="bg-primary-subtle"/>
            <c:set var="bigoText"  value="비고 없음"/>
        </c:if>
        <c:forEach var="orderInvoice" items="${ordersList}">
            <tr class="${colorClass}">
                <c:forEach var="course" items="${orderInvoice.courses}">
                    <td>${course.courseTitle}</td>
                    <td>1</td>
                    <c:set var="resultPrice" value="${course.coursePrice - (course.coursePrice * course.courseDiscount / 100)}"/>
                    <td>₩<fmt:formatNumber value="${resultPrice}" type="number" /></td>
                    <td>₩<fmt:formatNumber value="${resultPrice}" type="number" /></td>
                    <td>₩<fmt:formatNumber value="${resultPrice*0.1}" type="number" /></td>
                    <td>${bigoText}</td>
                </c:forEach>
            </tr>
        </c:forEach>
        </tbody>
        <tfoot>
        <tr class="summary">
            <td colspan="3">합계</td>
            <c:if test="${ordersList[0].ordersStatus eq 'CANC'}">
                <td>₩0</td>
                <td>₩0</td>
            </c:if>
            <c:if test="${ordersList[0].ordersStatus eq 'PAID'}">
                <td>₩<fmt:formatNumber value="${ordersList[0].ordersPrice}" type="number" /></td>
                <td>₩<fmt:formatNumber value="${ordersList[0].ordersPrice * 0.1}" type="number" /></td>
            </c:if>
            <td> </td>
        </tr>
        </tfoot>
    </table>

    <!-- 비고 -->
    <div class="small text-muted">
        ※ 위 금액은 부가가치세 포함 금액입니다.
    </div>
</div>

<!-- 다운로드 버튼 -->
<div class="container my-4 d-flex justify-content-center gap-3" style="max-width: 900px;">
    <button class="btn btn-outline-primary" id="downloadBtn">
        <i class="bi bi-image me-1"></i> 이미지 저장
    </button>
    <button class="btn btn-outline-primary" id="downloadPdfBtn">
        <i class="bi bi-file-earmark-pdf me-1"></i> PDF 다운로드
    </button>
</div>

<!-- 스크립트 -->
<script>
    document.getElementById('downloadBtn').addEventListener('click', function () {
        html2canvas(document.querySelector("#invoice")).then(canvas => {
            const link = document.createElement("a");
            link.download = "거래명세서.png";
            link.href = canvas.toDataURL("image/png");
            link.click();
        });
    });

    document.getElementById('downloadPdfBtn').addEventListener('click', function () {
        html2canvas(document.querySelector("#invoice"), { scale: 2 }).then(canvas => {
            const imgData = canvas.toDataURL('image/png');
            const pdf = new jspdf.jsPDF('p', 'mm', 'a4');
            const imgProps = pdf.getImageProperties(imgData);
            const pdfWidth = pdf.internal.pageSize.getWidth();
            const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;
            pdf.addImage(imgData, 'PNG', 0, 0, pdfWidth, pdfHeight);
            pdf.save("거래명세서.pdf");
        });
    });
</script>

</body>
</html>
