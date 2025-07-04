<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<jsp:include page="/WEB-INF/views/admin/common/header.jsp"/>

<!-- Content Wrapper -->
<div id="content-wrapper" class="d-flex flex-column">
    <!-- Main Content -->
    <div id="content">
        <!-- Topbar -->
        <jsp:include page="/WEB-INF/views/admin/common/topbar.jsp"/>

        <!-- Begin Page Content -->
        <div class="container-fluid">
            <!-- Page Heading -->
            <div class="d-sm-flex align-items-center justify-content-between mb-4">
                <h1 class="h3 mb-0 text-gray-800">
                    <i class="fas fa-user-check mr-2"></i>코치 승인 관리
                </h1>
                <p class="mb-0 text-gray-600">코치 신청을 검토하고 승인/거절을 처리합니다.</p>
            </div>

            <!-- Content Row - 통계 카드 -->
            <div class="row">
                <!-- 승인 대기 -->
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card border-left-warning shadow h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-warning text-uppercase mb-1">
                                        승인 대기
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="pendingCount">0</div>
                                </div>
                                <div class="col-auto">
                                    <i class="fas fa-clock fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 승인 완료 -->
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card border-left-success shadow h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                        승인 완료
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="approvedCount">0</div>
                                </div>
                                <div class="col-auto">
                                    <i class="fas fa-check-circle fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 승인 거절 -->
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card border-left-danger shadow h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">
                                        승인 거절
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="rejectedCount">0</div>
                                </div>
                                <div class="col-auto">
                                    <i class="fas fa-times-circle fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 전체 신청 -->
                <div class="col-xl-3 col-md-6 mb-4">
                    <div class="card border-left-primary shadow h-100 py-2">
                        <div class="card-body">
                            <div class="row no-gutters align-items-center">
                                <div class="col mr-2">
                                    <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                        전체 신청
                                    </div>
                                    <div class="h5 mb-0 font-weight-bold text-gray-800" id="totalCount">0</div>
                                </div>
                                <div class="col-auto">
                                    <i class="fas fa-users fa-2x text-gray-300"></i>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 필터 및 테이블 -->
            <div class="row">
                <div class="col-xl-12">
                    <div class="card shadow mb-4">
                        <!-- Card Header -->
                        <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                            <h6 class="m-0 font-weight-bold text-primary">코치 신청 목록</h6>
                        </div>

                        <!-- Card Body -->
                        <div class="card-body">
                            <!-- 필터 섹션 -->
                            <div class="row mb-4">
                                <div class="col-md-3">
                                    <label for="statusFilter" class="form-label">상태</label>
                                    <select class="form-control" id="statusFilter">
                                        <option value="" selected>전체</option>
                                        <option value="D">승인 대기</option>
                                        <option value="Y">승인 완료</option>
                                        <option value="N">승인 거절</option>
                                    </select>
                                </div>

                                <div class="col-md-3">
                                    <label for="searchInput" class="form-label">검색</label>
                                    <input type="text" class="form-control" id="searchInput" placeholder="이름, 이메일로 검색">
                                </div>

                                <div class="col-md-3">
                                    <label for="dateRange" class="form-label">신청일</label>
                                    <input type="date" class="form-control" id="dateRange">
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label">&nbsp;</label>
                                    <button class="btn btn-primary form-control" onclick="applyFilters()">
                                        <i class="fas fa-search mr-2"></i>검색
                                    </button>
                                </div>
                            </div>

                            <!-- 테이블 -->
                            <div class="table-responsive">
                                <table class="table table-bordered" id="dataTable" width="100%" cellspacing="0">
                                    <thead>
                                    <tr>
                                        <th>신청자 정보</th>
                                        <th>신청일</th>
                                        <th>계좌 정보</th>
                                        <th>상태</th>
                                        <th>처리일</th>
                                        <th>관리</th>
                                    </tr>
                                    </thead>
                                    <tbody id="coachApplyList">
                                    <!-- 동적으로 생성될 내용 -->
                                    </tbody>
                                </table>
                            </div>

                            <!-- 빈 상태 -->
                            <div class="text-center py-5" id="emptyState" style="display: none;">
                                <i class="fas fa-inbox fa-3x text-gray-400 mb-3"></i>
                                <h4 class="text-gray-600">신청 내역이 없습니다</h4>
                                <p class="text-gray-500">검색 조건을 변경해보세요.</p>
                            </div>

                            <!-- 페이지네이션 -->
                            <nav aria-label="Page navigation">
                                <ul class="pagination justify-content-center" id="pagination">
                                    <!-- 동적으로 생성될 내용 -->
                                </ul>
                            </nav>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /.container-fluid -->
    </div>
    <!-- End of Main Content -->
</div>
<!-- End of Content Wrapper -->

<!-- 상세보기 모달 -->
<div class="modal fade" id="detailModal" tabindex="-1" role="dialog" aria-labelledby="detailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="detailModalLabel">
                    <i class="fas fa-user-edit mr-2"></i>코치 신청 상세정보
                </h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <!-- 신청자 정보 -->
                <div class="card mb-3">
                    <div class="card-header">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-user mr-2"></i>신청자 정보
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <p><strong>회원번호:</strong> <span id="detailMemberNo">-</span></p>
                                <p><strong>이름:</strong> <span id="detailName">-</span></p>
                                <p><strong>닉네임:</strong> <span id="detailNickname">-</span></p>
                            </div>
                            <div class="col-md-6">
                                <p><strong>이메일:</strong> <span id="detailEmail">-</span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 계좌 정보 -->
                <div class="card mb-3">
                    <div class="card-header">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-credit-card mr-2"></i>계좌 정보
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-4">
                                <p><strong>예금주:</strong> <span id="detailCoaBankName">-</span></p>
                            </div>
                            <div class="col-md-4">
                                <p><strong>은행명:</strong> <span id="detailCoaBank">-</span></p>
                            </div>
                            <div class="col-md-4">
                                <p><strong>계좌번호:</strong> <span id="detailCoaBankNum">-</span></p>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 소개 -->
                <div class="card mb-3">
                    <div class="card-header">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-file-text mr-2"></i>코치 소개
                        </h6>
                    </div>
                    <div class="card-body">
                        <p id="detailCoaIntro" class="mb-0">-</p>
                    </div>
                </div>

                <!-- 승인/거절 섹션 -->
                <div class="card" id="approvalSection" style="display: none;">
                    <div class="card-header">
                        <h6 class="m-0 font-weight-bold text-primary">
                            <i class="fas fa-check-square mr-2"></i>승인 처리
                        </h6>
                    </div>
                    <div class="card-body">
                        <div class="form-check mb-2">
                            <input class="form-check-input" type="radio" name="approvalStatus" id="approveRadio" value="Y">
                            <label class="form-check-label" for="approveRadio">
                                <i class="fas fa-check-circle text-success mr-1"></i>승인
                            </label>
                        </div>
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="radio" name="approvalStatus" id="rejectRadio" value="R">
                            <label class="form-check-label" for="rejectRadio">
                                <i class="fas fa-times-circle text-danger mr-1"></i>거절
                            </label>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">닫기</button>
                <button type="button" class="btn btn-primary" id="saveBtn" onclick="saveApproval()" style="display: none;">
                    <i class="fas fa-save mr-2"></i>저장
                </button>
            </div>
        </div>
    </div>
</div>

<!-- 로딩 오버레이 -->
<div class="modal fade" id="loadingModal" tabindex="-1" role="dialog" aria-hidden="true" data-backdrop="static">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-body text-center">
                <div class="spinner-border text-primary mb-3" role="status">
                    <span class="sr-only">처리 중...</span>
                </div>
                <p class="mb-0">처리 중입니다...</p>
            </div>
        </div>
    </div>
</div>

<script>
// Context Path를 JSP 표현식으로 가져오기
const contextPath = '${pageContext.request.contextPath}';

// 전역 변수
let currentPage = 1;
let currentCoachSeq = null;

// 페이지 로드 시 초기화
$(document).ready(function() {
    console.log("현재 Context Path:", contextPath); // 디버깅용
    loadCoachApplyList();
    updateStatistics();

    // Enter 키 이벤트
    $('#searchInput').on('keypress', function(e) {
        if (e.key === 'Enter') {
            applyFilters();
        }
    });

    // 모달 이벤트 - showDetail 함수에서 처리하므로 제거
    // $('#detailModal').on('show.bs.modal', function(e) {
    //     const button = $(e.relatedTarget);
    //     const coachSeq = button.data('seq');
    //     loadCoachDetail(coachSeq);
    // });

    // 승인 상태 라디오 버튼 변경 시
    $('input[name="approvalStatus"]').on('change', function() {
        $('#saveBtn').show();
    });
});

// 코치 신청 목록 로드
function loadCoachApplyList() {
    const status = $('#statusFilter').val();
    const searchKeyword = $('#searchInput').val();
    const applyDate = $('#dateRange').val();

    console.log("API 호출 URL:", contextPath + '/admin/coach/apply/list'); // 디버깅용

    $.ajax({
        url: contextPath + '/admin/coach/apply/list',
        method: 'GET',
        data: {
            status: status,
            searchKeyword: searchKeyword,
            applyDate: applyDate
        },
        success: function(response) {
            console.log('API 응답:', response);
            updateCounts(response.counts);
            updateList(response.applyList);
        },
        error: function(xhr, status, error) {
            console.error('데이터 로드 실패:', error);
            console.error('상태 코드:', xhr.status);
            console.error('에러 메시지:', xhr.responseText);
            alert('데이터를 불러오는데 실패했습니다.');
        }
    });
}

// 통계 카운트 업데이트
function updateCounts(counts) {
    if (counts) {
        $('#pendingCount').text(counts.pending || 0);
        $('#approvedCount').text(counts.approved || 0);
        $('#rejectedCount').text(counts.rejected || 0);
        $('#totalCount').text(counts.total || 0);
    }
}

// 코치 목록 업데이트
function updateList(list) {
    const tbody = $('#coachApplyList');
    tbody.empty();

    if (!list || list.length === 0) {
        $('#emptyState').show();
        $('#dataTable').hide();
        return;
    }

    $('#emptyState').hide();
    $('#dataTable').show();

    list.forEach(function(coach) {
        console.log('코치 데이터:', coach); // 디버깅용 로그
        
        const statusClass = coach.coaYn === 'D' ? 'warning' :
            coach.coaYn === 'Y' ? 'success' : 'danger';
        const statusText = coach.coaYn === 'D' ? '승인 대기' :
            coach.coaYn === 'Y' ? '승인 완료' : '승인 거절';

        const memberName = coach.memberName || '알 수 없음';
        const memberId = coach.memberId || '알 수 없음';
        const applyDate = coach.applyDate || new Date().toISOString();
        const processDate = coach.approveDate || null;

        const row = '<tr>' +
            '<td>' +
            '<div class="d-flex align-items-center">' +
            '<div class="mr-3">' +
            '<div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">' +
            memberName.charAt(0) +
            '</div>' +
            '</div>' +
            '<div>' +
            '<h6 class="mb-0">' + memberName + '</h6>' +
            '<small class="text-muted">' + memberId + '</small>' +
            '</div>' +
            '</div>' +
            '</td>' +
            '<td>' + formatDate(applyDate) + '</td>' +
            '<td>' +
            '<div>' + (coach.coaBank || '-') + '</div>' +
            '<small class="text-muted">' + maskAccountNumber(coach.coaBankNum) + '</small>' +
            '</td>' +
            '<td>' +
            '<span class="badge badge-' + statusClass + '">' + statusText + '</span>' +
            '</td>' +
            '<td>' + (processDate ? formatDate(processDate) : '-') + '</td>' +
            '<td>' +
            '<button class="btn btn-sm btn-primary mr-1" onclick="showDetail(' + coach.coaSeq + ')" title="상세보기">' +
            '<i class="fas fa-eye"></i> 상세보기' +
            '</button>' +
            (coach.coaYn === 'D' ?
                '<button class="btn btn-sm btn-success mr-1" onclick="quickApprove(' + coach.coaSeq + ')" title="승인">' +
                '<i class="fas fa-check"></i> 승인' +
                '</button>' +
                '<button class="btn btn-sm btn-danger" onclick="quickReject(' + coach.coaSeq + ')" title="거절">' +
                '<i class="fas fa-times"></i> 거절' +
                '</button>'
                : '') +
            '</td>' +
            '</tr>';
        tbody.append(row);
    });
}

// 계좌번호 마스킹
function maskAccountNumber(accountNumber) {
    if (!accountNumber) return '-';
    if (accountNumber.length <= 4) return accountNumber;
    return accountNumber.substring(0, 4) + '-****-' + accountNumber.substring(accountNumber.length - 4);
}

// 코치 목록 렌더링
function renderCoachList(list) {
    const tbody = $('#coachApplyList');
    tbody.empty();

    if (!list || list.length === 0) {
        $('#emptyState').show();
        $('#dataTable').hide();
        return;
    }

    $('#emptyState').hide();
    $('#emptyState').hide();
    $('#dataTable').show();

    list.forEach(function(coach) {
        const statusClass = coach.coaYn === 'N' ? 'warning' :
            coach.coaYn === 'Y' ? 'success' : 'danger';
        const statusText = coach.coaYn === 'N' ? '승인 대기' :
            coach.coaYn === 'Y' ? '승인 완료' : '승인 거절';

        // DTO 기준으로 필드명 수정 (실제 조인된 데이터는 서버에서 처리되어야 함)
        const memberName = coach.memberName || '알 수 없음';
        const memberId = coach.memberId || '알 수 없음';
        const applyDate = coach.applyDate || new Date().toISOString();
        const processDate = coach.processDate || null;

        const row = '<tr>' +
            '<td>' +
            '<div class="d-flex align-items-center">' +
            '<div class="mr-3">' +
            '<div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">' +
            memberName.charAt(0) +
            '</div>' +
            '</div>' +
            '<div>' +
            '<h6 class="mb-0">' + memberName + '</h6>' +
            '<small class="text-muted">' + memberId + '</small>' +
            '</div>' +
            '</div>' +
            '</td>' +
            '<td>' + formatDate(applyDate) + '</td>' +
            '<td>' +
            '<div>' + (coach.coaBank || '-') + '</div>' +
            '<small class="text-muted">' + maskAccountNumber(coach.coaBankNum) + '</small>' +
            '</td>' +
            '<td>' +
            '<span class="badge badge-' + statusClass + '">' + statusText + '</span>' +
            '</td>' +
            '<td>' + (processDate ? formatDate(processDate) : '-') + '</td>' +
            '<td>' +
            '<button class="btn btn-sm btn-primary mr-1" data-toggle="modal" ' +
            'data-target="#detailModal" data-seq="' + coach.coaSeq + '">' +
            '<i class="fas fa-eye">상세보기</i>' +
            '</button>' +
            (coach.coaYn === 'N' ?
                '<button class="btn btn-sm btn-success mr-1" onclick="quickApprove(' + coach.coaSeq + ')" title="승인">' +
                '<i class="fas fa-check">승인</i>' +
                '</button>' +
                '<button class="btn btn-sm btn-danger" onclick="quickReject(' + coach.coaSeq + ')" title="거절">' +
                '<i class="fas fa-times">거절</i>' +
                '</button>'
                : '') +
            '</td>' +
            '</tr>';
        tbody.append(row);
    });
}

// 코치 상세정보 로드
function loadCoachDetail(coachSeq) {
    currentCoachSeq = coachSeq;

    $.ajax({
        url: contextPath + `/admin/coach/apply/\${coachSeq}`,
        method: 'GET',
        success: function(apply) {
            console.log('loadCoachDetail 응답:', apply); // 디버깅용 로그
            
            // DTO 기준으로 필드명 수정
            $('#detailMemberNo').text(apply.memberNo || '-');
            $('#detailName').text(apply.memberName || '-');
            $('#detailNickname').text(apply.memberNickname || '-');
            $('#detailEmail').text(apply.memberId || '-');
            $('#detailJoinDate').text(formatDate(apply.memberEnrollDate) || '-');

            // 계좌 정보 (DTO 필드명 그대로 사용)
            $('#detailCoaBankName').text(apply.coaBankName || '-');
            $('#detailCoaBank').text(apply.coaBank || '-');
            $('#detailCoaBankNum').text(apply.coaBankNum || '-');

            // 소개 (DTO 필드명 그대로 사용)
            $('#detailCoaIntro').text(apply.coaIntro || '소개글이 없습니다.');

            // 승인 섹션 표시 여부
            if (apply.coaYn === 'N') {
                $('#approvalSection').show();
                $('#saveBtn').hide();
                $('input[name="approvalStatus"]').prop('checked', false);
                $('#adminComment').val('');
            } else {
                $('#approvalSection').hide();
                $('#saveBtn').hide();
            }
        },
        error: function() {
            alert('상세정보를 불러오는데 실패했습니다.');
        }
    });
}

// 승인 처리 저장
function saveApproval() {
    const status = $('input[name="approvalStatus"]:checked').val();
    const comment = $('#adminComment').val();

    if (!status) {
        alert('승인 또는 거절을 선택해주세요.');
        return;
    }

    if (confirm(status === 'Y' ? '승인하시겠습니까?' : '거절하시겠습니까?')) {
        showLoading();

        $.ajax({
            url: contextPath + `/admin/coach/apply/\${currentCoachSeq}/status`,
            type: 'POST',
            data: { status: status, comment: comment },
            success: function() {
                alert(status === 'Y' ? '승인되었습니다.' : '거절되었습니다.');
                $('#detailModal').modal('hide');
                loadCoachApplyList();
                updateStatistics();
                hideLoading();
            },
            error: function() {
                alert('처리 중 오류가 발생했습니다.');
                hideLoading();
            }
        });
    }
}

// 빠른 승인
function quickApprove(coachSeq) {
    if (confirm('승인하시겠습니까?')) {
        processCoach(coachSeq, 'Y');
    }
}

// 빠른 거절
function quickReject(coachSeq) {
    if (confirm('거절하시겠습니까?')) {
        processCoach(coachSeq, 'N');
    }
}

// 코치 처리
function processCoach(coachSeq, status) {
    showLoading();

    $.ajax({
        url: contextPath + `/admin/coach/apply/\${coachSeq}/status`,
        type: 'POST',
        data: { status: status },
        success: function() {
            alert(status === 'Y' ? '승인되었습니다.' : '거절되었습니다.');
            loadCoachApplyList();
            updateStatistics();
            hideLoading();
        },
        error: function() {
            alert('처리 중 오류가 발생했습니다.');
            hideLoading();
        }
    });
}

// 통계 업데이트
function updateStatistics() {
    $.ajax({
        url: contextPath + '/admin/coach/statistics',
        type: 'GET',
        success: function(data) {
            $('#pendingCount').text(data.pending || 0);
            $('#approvedCount').text(data.approved || 0);
            $('#rejectedCount').text(data.rejected || 0);
            $('#totalCount').text(data.total || 0);
        }
    });
}

// 페이지네이션 렌더링
function renderPagination(totalPages) {
    const pagination = $('#pagination');
    pagination.empty();

    if (totalPages <= 1) return;

    // 이전 버튼
    pagination.append(
        '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
        '<a class="page-link" href="#" onclick="changePage(' + (currentPage - 1) + ')">이전</a>' +
        '</li>'
    );

    // 페이지 번호
    for (let i = 1; i <= totalPages; i++) {
        pagination.append(
            '<li class="page-item ' + (currentPage === i ? 'active' : '') + '">' +
            '<a class="page-link" href="#" onclick="changePage(' + i + ')">' + i + '</a>' +
            '</li>'
        );
    }

    // 다음 버튼
    pagination.append(
        '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
        '<a class="page-link" href="#" onclick="changePage(' + (currentPage + 1) + ')">다음</a>' +
        '</li>'
    );
}

// 페이지 변경
function changePage(page) {
    currentPage = page;
    loadCoachApplyList();
}

// 필터 적용
function applyFilters() {
    currentPage = 1;
    loadCoachApplyList();
}

// 날짜 포맷
function formatDate(dateString) {
    if (!dateString) return '-';
    const date = new Date(dateString);
    return date.toLocaleDateString('ko-KR');
}

// 로딩 표시
function showLoading() {
    $('#loadingModal').modal('show');
}

// 로딩 숨기기
function hideLoading() {
    $('#loadingModal').modal('hide');
}

// 상세 정보 표시
function showDetail(coaSeq) {
    console.log('showDetail 호출됨, coaSeq:', coaSeq); // 디버깅용 로그
    
    if (!coaSeq || coaSeq === 'null') {
        alert('유효하지 않은 코치 ID입니다.');
        return;
    }
    
    $.ajax({
        url: contextPath + `/admin/coach/apply/\${coaSeq}`,
        method: 'GET',
        success: function(response) {
            console.log('상세 정보 응답:', response); // 디버깅용 로그
            
            // 신청자 정보
            $('#detailMemberNo').text(response.memberNo || '-');
            $('#detailName').text(response.memberName || '-');
            $('#detailNickname').text(response.memberNickname || '-');
            $('#detailEmail').text(response.memberId || '-');
            
            // 계좌 정보
            $('#detailCoaBankName').text(response.coaBankName || '-');
            $('#detailCoaBank').text(response.coaBank || '-');
            $('#detailCoaBankNum').text(response.coaBankNum || '-');
            
            // 소개 정보
            $('#detailCoaIntro').text(response.coaIntro || '소개글이 없습니다.');
            
            // 승인 섹션 표시 여부
            if (response.coaYn === 'D') {
                $('#approvalSection').show();
                $('#saveBtn').show();
                $('input[name="approvalStatus"]').prop('checked', false);
            } else {
                $('#approvalSection').hide();
                $('#saveBtn').hide();
            }
            
            // 모달 표시
            $('#detailModal').modal('show');
        },
        error: function(xhr, status, error) {
            console.error('상세 정보 로드 실패:', error);
            console.error('상태 코드:', xhr.status);
            console.error('에러 메시지:', xhr.responseText);
            alert('상세 정보를 불러오는데 실패했습니다.');
        }
    });
}
</script>

<jsp:include page="/WEB-INF/views/admin/common/footer.jsp"/>