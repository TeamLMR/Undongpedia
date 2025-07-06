<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main class="main">
    <!-- Page Title -->
    <div class="page-title light-background">
        <div class="container">
            <nav class="breadcrumbs">
                <ol>
                    <li><a href="${pageContext.request.contextPath}">Home</a></li>
                    <li class="current">Payment Complete</li>
                </ol>
            </nav>
            <h1>결제 완료</h1>
        </div>
    </div>
    <!-- End Page Title -->

    <section class="payment-complete section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <div class="card border-0 shadow-sm p-4">
                        <div class="text-center mb-4">
                            <i class="bi bi-check-circle text-success" style="font-size: 3rem;"></i>
                            <h2 class="mt-3">결제가 실패하였습니다.</h2>
                            <p class="text-muted">장바구니로 돌아가시려면 아래 버튼을 클릭해주세요.</p>
                        </div>

                        <div class="text-center mt-5">
                            <a href="${pageContext.request.contextPath}/cart" class="btn btn-primary btn-lg">
                                <i class="bi bi-cart me-2"></i>카트로 이동
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
