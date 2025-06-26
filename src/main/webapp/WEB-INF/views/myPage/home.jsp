<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="loginMember" value="${sessionScope.SPRING_SECURITY_CONTEXT.authentication.principal}"/>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<!-- Bootstrap CSS -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.10.0/font/bootstrap-icons.min.css" rel="stylesheet">

<section>
    <div class="account-page">
        <div class="container">
            <!-- 모바일 사이드바 토글 버튼 -->
            <div class="sidebar-toggle d-lg-none mb-3">
                <button class="btn btn-toggle" type="button" data-bs-toggle="collapse" data-bs-target="#profileSidebar" aria-expanded="false" aria-controls="profileSidebar">
                    <i class="bi bi-list me-2"></i> 프로필 메뉴
                </button>
            </div>

            <div class="row g-4"> <!-- g-4로 간격 추가 -->
                <!-- 프로필 사이드바 -->
                <div class="col-lg-3 profile-sidebar collapse d-lg-block" id="profileSidebar">
                    <div class="sidebar-content">
                        <div class="profile-header">
                            <div class="profile-avatar">
                                <span>${loginMember.memberNickname}</span>
                            </div>
                            <div class="profile-info">
                                <h4>${loginMember.memberNickname}</h4>
                                <div class="profile-email">
                                    <span>${loginMember.memberId}</span>
                                </div>
                            </div>
                        </div>

                        <div class="profile-nav">
                            <ul class="nav flex-column">
                                <li class="nav-item">
                                    <button class="nav-link active" data-page="/mypage/personal">
                                        <i class="bi bi-person-circle"></i>
                                        <span>회원정보</span>
                                    </button>
                                </li>
                                <li class="nav-item">
                                    <button class="nav-link" data-page="learning">
                                        <i class="bi bi-book"></i>
                                        <span>내 학습</span>
                                        <span class="badge">3</span>
                                    </button>
                                </li>
                                <li class="nav-item">
                                    <button class="nav-link" data-page="orders">
                                        <i class="bi bi-receipt"></i>
                                        <span>주문내역</span>
                                    </button>
                                </li>
                            </ul>

                            <h6 class="nav-section-title">서비스</h6>
                            <ul class="nav flex-column">
                                <li class="nav-item">
                                    <a href="/coach" class="nav-link">
                                        <i class="bi bi-person-workspace"></i>
                                        <span>코치실</span>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="#" class="nav-link logout">
                                        <i class="bi bi-box-arrow-right"></i>
                                        <span>로그아웃</span>
                                    </a>
                                </li>
                                <li class="nav-item">
                                    <a href="#" class="nav-link" onclick="confirmWithdrawal()">
                                        <i class="bi bi-person-x"></i>
                                        <span>회원탈퇴</span>
                                    </a>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>

                <!-- 프로필 콘텐츠 -->
                <div class="col-lg-9 profile-content">
                    <div class="content-wrapper">
                        <div id="content-area">
                            <div class="loading">
                                <i class="bi bi-arrow-clockwise"></i>
                                <p>로딩 중...</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- Bootstrap JS -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
<!-- jQuery -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.0/jquery.min.js"></script>

<script>
    $(document).ready(function() {
        // 페이지 로드시 첫 번째 메뉴 로드
        loadPage('personal');

        // 사이드바 메뉴 클릭 이벤트
        $('.profile-nav .nav-link[data-page]').on('click', function() {
            const page = $(this).data('page');

            // 활성 메뉴 변경
            $('.profile-nav .nav-link').removeClass('active');
            $(this).addClass('active');

            // 페이지 로드
            loadPage(page);

            // 모바일에서 사이드바 닫기
            if (window.innerWidth < 992) {
                $('#profileSidebar').collapse('hide');
            }
        });

        // 로그아웃 클릭 이벤트
        $('.logout').on('click', function(e) {
            e.preventDefault();
            if (confirm('로그아웃 하시겠습니까?')) {
                window.location.href = '${pageContext.request.contextPath}/logout.do';
            }
        });
    });

    function confirmWithdrawal() {
        if (confirm('정말로 회원탈퇴를 하시겠습니까?\n\n탈퇴 시 모든 학습 데이터가 삭제되며 복구할 수 없습니다.')) {
            if (confirm('마지막 확인입니다.\n회원탈퇴를 진행하시겠습니까?')) {
                // 실제로는 서버로 탈퇴 요청
                window.location.href = '/member/withdrawal';
            }
        }
    }

    function loadPage(page) {
        // 로딩 표시
        $('#content-area').html(`
            <div class="loading">
                <div class="loading-spinner">
                    <i class="bi bi-arrow-clockwise"></i>
                </div>
                <p>로딩 중...</p>
            </div>
        `);

        // Ajax로 페이지 로드
        $.ajax({
            url: 'mypage/' + page,
            type: 'GET',
            success: function(data) {
                $('#content-area').html(data);

                // 콘텐츠 로드 후 애니메이션 효과
                $('#content-area').hide().fadeIn(300);

                // 모바일에서 콘텐츠 영역으로 스크롤
                if (window.innerWidth < 992) {
                    setTimeout(() => {
                        $('.content-wrapper')[0].scrollIntoView({
                            behavior: 'smooth',
                            block: 'start'
                        });
                    }, 100);
                }
            },
            error: function(xhr, status, error) {
                $('#content-area').html(`
                    <div class="error-state">
                        <div class="error-icon">
                            <i class="bi bi-exclamation-triangle"></i>
                        </div>
                        <div class="error-content">
                            <h4>오류가 발생했습니다!</h4>
                            <p>페이지를 불러오는 중 문제가 발생했습니다.</p>
                            <button class="btn btn-primary btn-sm" onclick="location.reload()">
                                <i class="bi bi-arrow-clockwise me-1"></i>새로고침
                            </button>
                        </div>
                    </div>
                `);
            }
        });
    }

    // 창 크기 변경 시 사이드바 상태 조정
    $(window).on('resize', function() {
        if (window.innerWidth >= 992) {
            $('#profileSidebar').removeClass('collapse').addClass('d-lg-block');
        } else {
            $('#profileSidebar').addClass('collapse').removeClass('d-lg-block');
        }
    });
</script>

<style>
    .account-page {
        background-color: #f8f9fa;
        min-height: 100vh;
        padding: 2rem 0;
    }

    .profile-sidebar {
        height: fit-content;
    }

    .sidebar-content {
        background: white;
        border-radius: 12px;
        padding: 2rem;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        position: sticky;
        top: 2rem;
    }

    .profile-header {
        text-align: center;
        margin-bottom: 2rem;
        padding-bottom: 2rem;
        border-bottom: 1px solid #dee2e6;
    }

    .profile-avatar {
        width: 80px;
        height: 80px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 1rem;
        color: white;
        font-size: 2rem;
        font-weight: bold;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
    }

    .profile-info h4 {
        margin: 0 0 0.5rem 0;
        color: #333;
        font-weight: 600;
    }

    .profile-email {
        color: #6c757d;
        font-size: 0.9rem;
    }

    .profile-nav .nav-link {
        display: flex;
        align-items: center;
        padding: 1rem 1.25rem;
        border: none;
        background: none;
        width: 100%;
        text-align: left;
        color: #6c757d;
        border-radius: 10px;
        margin-bottom: 0.5rem;
        transition: all 0.3s ease;
        font-weight: 500;
    }

    .profile-nav .nav-link:hover {
        background: #f8f9fa;
        color: #007bff;
        transform: translateX(5px);
    }

    .profile-nav .nav-link.active {
        background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
        color: white;
        box-shadow: 0 4px 15px rgba(0,123,255,0.3);
    }

    .profile-nav .nav-link i {
        margin-right: 0.75rem;
        font-size: 1.1rem;
        width: 20px;
        text-align: center;
    }

    .profile-nav .badge {
        margin-left: auto;
        background: #dc3545;
        border-radius: 12px;
        padding: 0.25rem 0.5rem;
        font-size: 0.75rem;
    }

    .profile-nav .nav-link.active .badge {
        background: rgba(255,255,255,0.2);
        color: white;
    }

    .nav-section-title {
        color: #999;
        font-size: 0.85rem;
        font-weight: 600;
        margin: 2rem 0 1rem;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        padding-left: 1.25rem;
    }

    .content-wrapper {
        background: white;
        border-radius: 12px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
        min-height: 600px;
        overflow: hidden;
    }

    #content-area {
        padding: 0; /* 패딩 제거 - Ajax 콘텐츠가 자체 패딩 관리 */
        min-height: 600px;
    }

    .loading {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 4rem 2rem;
        color: #6c757d;
        min-height: 400px;
    }

    .loading-spinner {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 1.5rem;
        box-shadow: 0 4px 20px rgba(0,123,255,0.3);
    }

    .loading-spinner i {
        font-size: 1.5rem;
        color: white;
        animation: spin 1s linear infinite;
    }

    .loading p {
        margin: 0;
        font-size: 1.1rem;
        font-weight: 500;
    }

    .error-state {
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        padding: 4rem 2rem;
        text-align: center;
        min-height: 400px;
    }

    .error-icon {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        background: #fff5f5;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 2rem;
        border: 3px solid #fed7d7;
    }

    .error-icon i {
        font-size: 2rem;
        color: #e53e3e;
    }

    .error-content h4 {
        color: #333;
        margin-bottom: 1rem;
    }

    .error-content p {
        color: #6c757d;
        margin-bottom: 2rem;
    }

    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }

    .sidebar-toggle {
        background: white;
        border-radius: 12px;
        padding: 1rem;
        box-shadow: 0 4px 20px rgba(0,0,0,0.08);
    }

    .btn-toggle {
        background: #007bff;
        color: white;
        border: none;
        border-radius: 8px;
        padding: 0.75rem 1rem;
        font-weight: 500;
        transition: all 0.3s ease;
    }

    .btn-toggle:hover {
        background: #0056b3;
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 4px 15px rgba(0,123,255,0.3);
    }

    .profile-nav .nav-link.text-danger {
        color: #dc3545 !important;
    }

    .profile-nav .nav-link.text-danger:hover {
        background: #fff5f5;
        color: #c82333 !important;
    }

    @media (max-width: 991.98px) {
        .account-page {
            padding: 1rem 0;
        }

        .sidebar-content {
            margin-bottom: 2rem;
            position: static;
        }

        .content-wrapper {
            margin-top: 1rem;
        }

        .profile-nav .nav-link {
            padding: 0.875rem 1rem;
        }

        .loading, .error-state {
            padding: 3rem 1rem;
            min-height: 300px;
        }
    }

    @media (max-width: 575.98px) {
        .account-page {
            padding: 0.5rem 0;
        }

        .sidebar-content,
        .content-wrapper {
            border-radius: 8px;
            padding: 1.5rem;
        }

        .profile-avatar {
            width: 60px;
            height: 60px;
            font-size: 1.5rem;
        }

        .profile-header {
            padding-bottom: 1.5rem;
            margin-bottom: 1.5rem;
        }
    }
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>