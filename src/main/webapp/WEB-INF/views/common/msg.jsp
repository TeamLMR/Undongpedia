<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>
<!-- Page Title -->
<div class="page-title light-background">
    <div class="container">
        <nav class="breadcrumbs">
            <ol>
                <li><a href="${pageContext.request.contextPath}">Home</a></li>
                <li class="current">Message</li>
            </ol>
        </nav>
        <h1>Message</h1>
    </div>
</div><!-- End Page Title -->
<section>
    <!-- Error 404 Section -->
    <section id="error-404" class="error-404 section">
        <div class="container" data-aos="fade-up" data-aos-delay="100">
            <div class="row g-0 align-items-center">
                <div class="col-lg-6" data-aos="fade-right" data-aos-delay="200">
                    <div class="error-content text-center text-lg-start">
                        <span class="error-badge" data-aos="fade-down" data-aos-delay="300">Message</span>
                        <h1 class="error-title mt-4" data-aos="fade-up" data-aos-delay="400">${msg}</h1>
                        <div class="error-actions mt-4" data-aos="fade-up" data-aos-delay="600">
                            <a href="${pageContext.request.contextPath}" class="btn btn-outline">
                                <i class="bi bi-arrow-left me-2"></i>Return Home
                            </a>
                        </div>
                    </div>
                </div>

                <div class="col-lg-6" data-aos="fade-left" data-aos-delay="200">
                    <div class="error-illustration text-center">
                        <div class="illustration-container">
                            <div class="planet">
                                <i class="bi bi-globe2"></i>
                            </div>
                            <div class="astronaut">
                                <i class="bi bi-person-workspace"></i>
                            </div>
                            <div class="stars">
                                <i class="bi bi-star-fill star-1"></i>
                                <i class="bi bi-star-fill star-2"></i>
                                <i class="bi bi-star-fill star-3"></i>
                                <i class="bi bi-star-fill star-4"></i>
                                <i class="bi bi-star-fill star-5"></i>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </section><!-- /Error 404 Section -->
</section>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>