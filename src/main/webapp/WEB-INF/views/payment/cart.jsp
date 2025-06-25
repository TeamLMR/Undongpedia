<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<main class="main">
    <!-- Page Title -->
    <div class="page-title light-background">
        <div class="container">
            <nav class="breadcrumbs">
                <ol>
                    <li><a href="${pageContext.request.contextPath}">Home</a></li>
                    <li class="current">Cart</li>
                </ol>
            </nav>
            <h1>Cart</h1>
        </div>
    </div><!-- End Page Title -->
    <section>
        <!-- Cart Section -->
        <section id="cart" class="cart section">
            <div class="container" data-aos="fade-up" data-aos-delay="100">
                <div class="row">
                    <div class="col-lg-8" data-aos="fade-up" data-aos-delay="200">
                        <div class="cart-items">
                            <div class="cart-header d-none d-lg-block">
                                <div class="row align-items-center">
                                    <div class="col-lg-8">
                                        <h5>상품 이름</h5>
                                    </div>
                                    <div class="col-lg-4 text-center">
                                        <h5>금액</h5>
                                    </div>
                                </div>
                            </div>
                            <div class="cart-item">
                                <div class="row align-items-center">
                                    <div class="col-lg-8 col-12 mt-3 mt-lg-0 mb-lg-0 mb-3">
                                        <div class="product-info d-flex align-items-center">
                                            <div class="product-image">
                                                <img src="${pageContext.request.contextPath}/resources/images/dummy.webp" alt="Product" class="w-100 h-100 object-fit-cover" loading="lazy">
                                            </div>
                                            <div class="product-details">
                                                <h6 class="product-title">dummy</h6>
                                                <button class="remove-item" type="button">
                                                    <i class="bi bi-trash"></i> Remove
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-lg-4 col-12 mt-3 mt-lg-0 text-center">
                                        <div class="price-tag">
                                            <div class="text-danger fs-5 text-end">
                                                <span id="discount">0</span>
                                                <span>%</span>
                                            </div>
                                            <div class="original-price text-secondary text-start">
                                                <span>₩</span>
                                                <span id="origin-price">0,000</span>
                                                <span>-></span>
                                            </div>
                                            <div class="current-price fs-4 text-end">
                                                <span>₩</span>
                                                <span id="price">0,000</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div><!-- End Cart Item -->
                        </div>
                    </div>

                    <div class="col-lg-4 mt-4 mt-lg-0" data-aos="fade-up" data-aos-delay="300">
                        <div class="cart-summary">
                            <h4 class="summary-title">결제정보</h4>

                            <div class="summary-item">
                                <span class="summary-label">금액</span>
                                <span class="summary-value">₩</span>
                                <span class="summary-value">0</span>
                            </div>

                            <div class="summary-item discount">
                                <span class="summary-label">할인</span>
                                <span class="summary-value">-₩</span>
                                <span class="summary-value">0</span>
                            </div>

                            <div class="summary-total">
                                <span class="summary-label">총 금액</span>
                                <span class="summary-value">₩</span>
                                <span class="summary-value">0</span>
                            </div>

                            <div class="checkout-button" onclick="location.assign('${pageContext.request.contextPath}/payment/start')">
                                <img src= "${pageContext.request.contextPath}/resources/images/btn_npaygr_pay.svg" class="w-100" alt="">
                            </div>

                            <div class="continue-shopping">
                                <a href="${pageContext.request.contextPath}" class="btn btn-link w-100">
                                    <i class="bi bi-arrow-left"></i> 더 둘러보기
                                </a>
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </section><!-- /Cart Section -->
    </section>
</main>

<%--    /*--%>
<%--    * 1. 버튼으로 요청 받은 후 PaymentController--%>
<%--    * 2. PaymentController에서 해당 상품의 이름, 갯수, api 정보들을 세팅--%>
<%--    * 3. returnUrl 로 반환--%>
<%--    * 4-1. 결제 결과 성공 -> 유저 데이터에 수강목록 추가--%>
<%--    * 4-2  결제 결과 실패 -> 장바구니로 redirect--%>
<%--    * 5. ??--%>
<%--    * */--%>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>