<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main class="main">

    <!-- Hero Section -->
    <section class="ecommerce-hero-2 hero section" id="hero">
        <div class="container">
            <div class="hero-slider swiper init-swiper" data-aos="fade-up">
                <script type="application/json" class="swiper-config">
                    {
                        "loop": true,
                        "speed": 800,
                        "autoplay": {
                            "delay": 5000
                        },
                        "effect": "fade",
                        "fadeEffect": {
                            "crossFade": true
                        },
                        "navigation": {
                            "nextEl": ".swiper-button-next",
                            "prevEl": ".swiper-button-prev"
                        }
                    }
                </script>
                <div class="swiper-wrapper">
                    <c:forEach var="i" begin="0" end="3">
                        <div class="swiper-slide slide-sale">
                            <div class="row align-items-center">
                                <div class="col-lg-6 content-col" data-aos="fade-right" data-aos-delay="100">
                                    <div class="slide-content">
                                        <span class="slide-badge">선착순</span>
                                        <h1>당신의 망가진 몸을 구해드립니다.</h1>
                                        <div class="slide-cta">
                                            <a href="#" class="btn btn-shop">Shop Sale <i class="bi bi-arrow-right"></i></a>
                                        </div>
                                        <div class="countdown-container">
                                            <div class="countdown-label">Offer ends in:</div>
                                            <div class="countdown d-flex" data-count="2025/6/15">
                                                <div>
                                                    <h3 class="count-days"></h3>
                                                    <h4>Days</h4>
                                                </div>
                                                <div>
                                                    <h3 class="count-hours"></h3>
                                                    <h4>Hours</h4>
                                                </div>
                                                <div>
                                                    <h3 class="count-minutes"></h3>
                                                    <h4>Minutes</h4>
                                                </div>
                                                <div>
                                                    <h3 class="count-seconds"></h3>
                                                    <h4>Seconds</h4>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-6 image-col" data-aos="fade-left" data-aos-delay="200">
                                    <div class="sale-showcase">
                                        <div class="main-product">
                                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-8.webp" alt="Sale Product">
                                            <div class="discount-badge">
                                                <span class="percent">50%</span>
                                                <span class="text">OFF</span>
                                            </div>
                                        </div>
                                        <div class="floating-tag" data-aos="zoom-in" data-aos-delay="300">
                                            <div class="tag-content">
                                                <span class="tag-label">Best Seller</span>
                                                <span class="tag-price">
                          <span class="old-price">$129.99</span>
                          <span class="new-price">$64.99</span>
                        </span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </c:forEach>
                </div>

                <div class="swiper-button-prev"></div>
                <div class="swiper-button-next"></div>
            </div>
        </div>
    </section><!-- /Hero Section -->

    <!-- Promo Cards Section -->
    <section id="promo-cards" class="promo-cards section">

        <div class="container" data-aos="fade-up" data-aos-delay="100">

            <div class="row g-4">
                <!-- Promo Card 1 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="100">
                    <div class="promo-card card-1">
                        <div class="promo-content">
                            <p class="small-text">Etiam vel augue</p>
                            <h3 class="promo-title">Nullam quis ante</h3>
                            <p class="promo-description">Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu in enim justo rhoncus ut.</p>
                            <a href="#" class="btn-shop">Shop Now</a>
                        </div>
                        <div class="promo-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-1.webp" alt="Product" class="img-fluid">
                        </div>
                    </div>
                </div>

                <!-- Promo Card 2 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="200">
                    <div class="promo-card card-2">
                        <div class="promo-content">
                            <p class="small-text">Maecenas tempus</p>
                            <h3 class="promo-title">Sed fringilla mauris</h3>
                            <p class="promo-description">Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu in enim justo rhoncus ut.</p>
                            <a href="#" class="btn-shop">Shop Now</a>
                        </div>
                        <div class="promo-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-2.webp" alt="Product" class="img-fluid">
                        </div>
                    </div>
                </div>

                <!-- Promo Card 3 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="300">
                    <div class="promo-card card-3">
                        <div class="promo-content">
                            <p class="small-text">Aenean commodo</p>
                            <h3 class="promo-title">Fusce vulputate eleifend</h3>
                            <p class="promo-description">Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu in enim justo rhoncus ut.</p>
                            <a href="#" class="btn-shop">Shop Now</a>
                        </div>
                        <div class="promo-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-1.webp" alt="Product" class="img-fluid">
                        </div>
                    </div>
                </div>

                <!-- Promo Card 4 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="400">
                    <div class="promo-card card-4">
                        <div class="promo-content">
                            <p class="small-text">Pellentesque auctor</p>
                            <h3 class="promo-title">Vestibulum dapibus nunc</h3>
                            <p class="promo-description">Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu in enim justo rhoncus ut.</p>
                            <a href="#" class="btn-shop">Shop Now</a>
                        </div>
                        <div class="promo-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-1.webp" alt="Product" class="img-fluid">
                        </div>
                    </div>
                </div>
            </div>

        </div>

    </section><!-- /Promo Cards Section -->

    <!-- Category Cards Section -->
    <section id="category-cards" class="category-cards section light-background">

        <div class="container" data-aos="fade-up" data-aos-delay="100">

            <div class="category-tabs">
                <ul class="nav justify-content-center" id="category-cards-tabs" role="tablist">
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="category-cards-men-tab" data-bs-toggle="tab" data-bs-target="#category-cards-men-content" type="button" role="tab" aria-controls="category-cards-men-content" aria-selected="false">SHOP MEN</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link active" id="category-cards-women-tab" data-bs-toggle="tab" data-bs-target="#category-cards-women-content" type="button" role="tab" aria-controls="category-cards-women-content" aria-selected="true">SHOP WOMEN</button>
                    </li>
                    <li class="nav-item" role="presentation">
                        <button class="nav-link" id="category-cards-accesoires-tab" data-bs-toggle="tab" data-bs-target="#category-cards-accesoires-content" type="button" role="tab" aria-controls="category-cards-accesoires-content" aria-selected="false">SHOP ACCESSOIRCES</button>
                    </li>
                </ul>
            </div>

            <div class="tab-content" id="category-cards-tabContent">
                <!-- Men's Categories -->
                <div class="tab-pane fade" id="category-cards-men-content" role="tabpanel" aria-labelledby="category-cards-men-tab">
                    <div class="row g-4">
                        <!-- Leather Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="200">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-11.webp" alt="Men's Leather" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    LEATHER <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Denim Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="300">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-12.webp" alt="Men's Denim" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    DENIM <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Swimwear Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="400">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-19.webp" alt="Men's Swimwear" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    SWIMWEAR <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Women's Categories -->
                <div class="tab-pane fade show active" id="category-cards-women-content" role="tabpanel" aria-labelledby="category-cards-women-tab">
                    <div class="row g-4">
                        <!-- Dresses Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="200">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-11.webp" alt="Women's Dresses" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    DRESSES <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Tops Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="300">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-18.webp" alt="Women's Tops" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    TOPS <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Accessories Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="400">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-13.webp" alt="Women's Accessories" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    ACCESSORIES <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Kid's Categories -->
                <div class="tab-pane fade" id="category-cards-accesoires-content" role="tabpanel" aria-labelledby="category-cards-accesoires-tab">
                    <div class="row g-4">
                        <!-- Boys Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="200">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-1.webp" alt="Boys Clothing" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    BOYS <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Girls Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="300">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-2.webp" alt="Girls Clothing" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    GIRLS <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>

                        <!-- Toys Category -->
                        <div class="col-12 col-md-4" data-aos="fade-up" data-aos-delay="400">
                            <div class="category-card">
                                <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-3.webp" alt="Kids Toys" class="img-fluid" loading="lazy">
                                <a href="#" class="category-link">
                                    TOYS <i class="bi bi-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>

    </section><!-- /Category Cards Section -->

    <!-- Best Sellers Section -->
    <section id="best-sellers" class="best-sellers section">

        <!-- Section Title -->
        <div class="container section-title" data-aos="fade-up">
            <h2>Best Sellers</h2>
            <p>Necessitatibus eius consequatur ex aliquid fuga eum quidem sint consectetur velit</p>
        </div><!-- End Section Title -->

        <div class="container" data-aos="fade-up" data-aos-delay="100">

            <div class="row g-4">
                <!-- Product 1 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-1.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-2.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Women's Fashion</div>
                            <h4 class="product-title"><a href="product-details.html">Tempor Incididunt</a></h4>
                            <div class="product-meta">
                                <div class="product-price">$129.00</div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.8 <span>(42)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 2 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="100">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-1.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-2.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="product-badge new">New</div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Men's Collection</div>
                            <h4 class="product-title"><a href="product-details.html">Elit Consectetur</a></h4>
                            <div class="product-meta">
                                <div class="product-price">$95.00</div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.6 <span>(28)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 3 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="200">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-3.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-4.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="product-badge sale">-25%</div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Accessories</div>
                            <h4 class="product-title"><a href="product-details.html">Adipiscing Magna</a></h4>
                            <div class="product-meta">
                                <div class="product-price">
                                    $75.00
                                    <span class="original-price">$99.00</span>
                                </div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.9 <span>(56)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 4 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="300">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-3.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-4.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Footwear</div>
                            <h4 class="product-title"><a href="product-details.html">Labore Dolore</a></h4>
                            <div class="product-meta">
                                <div class="product-price">$145.00</div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.7 <span>(35)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 5 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="400">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-5.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-6.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Men's Fashion</div>
                            <h4 class="product-title"><a href="product-details.html">Magna Aliqua</a></h4>
                            <div class="product-meta">
                                <div class="product-price">$89.00</div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.5 <span>(23)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 6 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="500">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-5.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-6.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="product-badge sale">-15%</div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Women's Fashion</div>
                            <h4 class="product-title"><a href="product-details.html">Eiusmod Tempor</a></h4>
                            <div class="product-meta">
                                <div class="product-price">
                                    $110.00
                                    <span class="original-price">$129.00</span>
                                </div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.8 <span>(47)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 7 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="600">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-7.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-f-8.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Accessories</div>
                            <h4 class="product-title"><a href="product-details.html">Incididunt Labore</a></h4>
                            <div class="product-meta">
                                <div class="product-price">$55.00</div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.6 <span>(31)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Product 8 -->
                <div class="col-6 col-lg-3">
                    <div class="product-card" data-aos="zoom-in" data-aos-delay="700">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-7.webp" class="main-image img-fluid" alt="Product">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-m-8.webp" class="hover-image img-fluid" alt="Product Variant">
                            <div class="product-overlay">
                                <div class="product-actions">
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Quick View">
                                        <i class="bi bi-eye"></i>
                                    </button>
                                    <button type="button" class="action-btn" data-bs-toggle="tooltip" title="Add to Cart">
                                        <i class="bi bi-cart-plus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="product-badge new">New</div>
                        </div>
                        <div class="product-details">
                            <div class="product-category">Men's Fashion</div>
                            <h4 class="product-title"><a href="product-details.html">Aliqua Magna</a></h4>
                            <div class="product-meta">
                                <div class="product-price">$79.00</div>
                                <div class="product-rating">
                                    <i class="bi bi-star-fill"></i>
                                    4.7 <span>(39)</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

        </div>

    </section><!-- /Best Sellers Section -->

    <!-- Product List Section -->
    <section id="product-list" class="product-list section">

        <div class="container isotope-layout" data-aos="fade-up" data-aos-delay="100" data-default-filter="*" data-layout="masonry" data-sort="original-order">

            <div class="row">
                <div class="col-12">
                    <div class="product-filters isotope-filters mb-5 d-flex justify-content-center" data-aos="fade-up">
                        <ul class="d-flex flex-wrap gap-2 list-unstyled">
                            <li class="filter-active" data-filter="*">All</li>
                            <li data-filter=".filter-clothing">Clothing</li>
                            <li data-filter=".filter-accessories">Accessories</li>
                            <li data-filter=".filter-electronics">Electronics</li>
                        </ul>
                    </div>
                </div>
            </div>

            <div class="row product-container isotope-container" data-aos="fade-up" data-aos-delay="200">

                <!-- Product Item 1 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-clothing">
                    <div class="product-card">
                        <div class="product-image">
                            <span class="badge">Sale</span>
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-1.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-1-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Lorem ipsum dolor sit amet</a></h5>
                            <div class="product-price">
                                <span class="current-price">$89.99</span>
                                <span class="old-price">$129.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-half"></i>
                                <span>(24)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 2 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-electronics">
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-2.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-2-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Consectetur adipiscing elit</a></h5>
                            <div class="product-price">
                                <span class="current-price">$249.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star"></i>
                                <span>(18)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 3 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-accessories">
                    <div class="product-card">
                        <div class="product-image">
                            <span class="badge">New</span>
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-3.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-3-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Sed do eiusmod tempor</a></h5>
                            <div class="product-price">
                                <span class="current-price">$59.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star"></i>
                                <i class="bi bi-star"></i>
                                <span>(7)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 4 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-clothing">
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-4.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-4-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Incididunt ut labore et dolore</a></h5>
                            <div class="product-price">
                                <span class="current-price">$79.99</span>
                                <span class="old-price">$99.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <span>(32)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 5 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-electronics">
                    <div class="product-card">
                        <div class="product-image">
                            <span class="badge">Sale</span>
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-5.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-5-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Magna aliqua ut enim ad minim</a></h5>
                            <div class="product-price">
                                <span class="current-price">$199.99</span>
                                <span class="old-price">$249.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-half"></i>
                                <i class="bi bi-star"></i>
                                <span>(15)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 6 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-accessories">
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-6.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-6-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Veniam quis nostrud exercitation</a></h5>
                            <div class="product-price">
                                <span class="current-price">$45.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star"></i>
                                <span>(21)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 7 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-clothing">
                    <div class="product-card">
                        <div class="product-image">
                            <span class="badge">New</span>
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-7.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-7-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Ullamco laboris nisi ut aliquip</a></h5>
                            <div class="product-price">
                                <span class="current-price">$69.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-half"></i>
                                <i class="bi bi-star"></i>
                                <span>(11)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

                <!-- Product Item 8 -->
                <div class="col-md-6 col-lg-3 product-item isotope-item filter-electronics">
                    <div class="product-card">
                        <div class="product-image">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-8.webp" alt="Product" class="img-fluid main-img">
                            <img src="${pageContext.request.contextPath}/resources/assets/img/product/product-8-variant.webp" alt="Product Hover" class="img-fluid hover-img">
                            <div class="product-overlay">
                                <a href="cart.html" class="btn-cart"><i class="bi bi-cart-plus"></i> Add to Cart</a>
                                <div class="product-actions">
                                    <a href="#" class="action-btn"><i class="bi bi-heart"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-eye"></i></a>
                                    <a href="#" class="action-btn"><i class="bi bi-arrow-left-right"></i></a>
                                </div>
                            </div>
                        </div>
                        <div class="product-info">
                            <h5 class="product-title"><a href="product-details.html">Ex ea commodo consequat</a></h5>
                            <div class="product-price">
                                <span class="current-price">$159.99</span>
                            </div>
                            <div class="product-rating">
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <i class="bi bi-star-fill"></i>
                                <span>(29)</span>
                            </div>
                        </div>
                    </div>
                </div><!-- End Product Item -->

            </div>

            <div class="text-center mt-5" data-aos="fade-up">
                <a href="category.html" class="view-all-btn">View All Products <i class="bi bi-arrow-right"></i></a>
            </div>

        </div>

    </section><!-- /Product List Section -->

</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

