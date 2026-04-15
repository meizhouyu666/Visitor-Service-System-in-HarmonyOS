package com.visitor.service.bootstrap;

import com.visitor.service.user.UserAccount;
import com.visitor.service.user.UserRepository;
import com.visitor.service.user.UserRole;
import com.visitor.service.complaint.Complaint;
import com.visitor.service.complaint.ComplaintRepository;
import com.visitor.service.complaint.ComplaintStatus;
import com.visitor.service.emergency.EmergencyInfo;
import com.visitor.service.emergency.EmergencyInfoRepository;
import com.visitor.service.emergency.EmergencyStatus;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class DataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final ComplaintRepository complaintRepository;
    private final EmergencyInfoRepository emergencyInfoRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(UserRepository userRepository,
                          ComplaintRepository complaintRepository,
                          EmergencyInfoRepository emergencyInfoRepository,
                          PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.complaintRepository = complaintRepository;
        this.emergencyInfoRepository = emergencyInfoRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        // 创建初始用户
        UserAccount visitor = createUserIfAbsent("visitor", "visitor123", "Visitor Demo", UserRole.VISITOR);
        UserAccount admin = createUserIfAbsent("admin", "admin123", "Admin Demo", UserRole.ADMIN);

        // 创建测试投诉数据
        createTestComplaints(visitor, admin);

        // 创建测试应急信息数据
        createTestEmergencyInfos(admin);
    }

    private UserAccount createUserIfAbsent(String username, String rawPassword, String displayName, UserRole role) {
        return userRepository.findByUsername(username)
                .orElseGet(() -> {
                    UserAccount user = new UserAccount();
                    user.setUsername(username);
                    user.setDisplayName(displayName);
                    user.setRole(role);
                    user.setPasswordHash(passwordEncoder.encode(rawPassword));
                    return userRepository.save(user);
                });
    }

    private void createTestComplaints(UserAccount visitor, UserAccount admin) {
        if (complaintRepository.count() > 0) {
            return; // 如果已经有投诉数据，不再创建
        }

        // 测试投诉数据1：关于景区卫生间的问题
        Complaint complaint1 = new Complaint();
        complaint1.setTitle("景区北门卫生间卫生状况不佳");
        complaint1.setContent("今天上午10点左右，在景区北门卫生间发现卫生状况很差，地面有水渍，垃圾桶已满未清理。建议增加清洁频次。");
        complaint1.setAttachmentUrls("photos/bathroom1.jpg,photos/bathroom2.jpg");
        complaint1.setStatus(ComplaintStatus.APPROVED);
        complaint1.setHandlerComment("已安排清洁人员前往处理，将在30分钟内完成清洁。");
        complaint1.setCreatedBy(visitor);
        complaintRepository.save(complaint1);

        // 测试投诉数据2：关于排队时间过长
        Complaint complaint2 = new Complaint();
        complaint2.setTitle("缆车排队时间过长超过1小时");
        complaint2.setContent("下午2点在缆车站排队，等待时间超过1小时，现场只有2个工作人员，效率较低。建议增加工作人员或优化排队流程。");
        complaint2.setAttachmentUrls("videos/queue1.mp4");
        complaint2.setStatus(ComplaintStatus.IN_PROGRESS);
        complaint2.setHandlerComment("已通知缆车运营部门，正在调派额外工作人员支援。");
        complaint2.setProcessedBy(admin);
        complaint2.setCreatedBy(visitor);
        complaintRepository.save(complaint2);

        // 测试投诉数据3：关于景区指示牌问题
        Complaint complaint3 = new Complaint();
        complaint3.setTitle("景区内指示牌破损不清晰");
        complaint3.setContent("在通往瀑布景点的路上，多个指示牌破损或字迹模糊，导致游客容易迷路。建议尽快修复或更换。");
        complaint3.setStatus(ComplaintStatus.RESOLVED);
        complaint3.setHandlerComment("已安排维修部门检查并修复，预计本周内完成。");
        complaint3.setClosureComment("指示牌已全部修复完毕，游客反馈良好。");
        complaint3.setRating(4);
        complaint3.setProcessedBy(admin);
        complaint3.setCreatedBy(visitor);
        complaintRepository.save(complaint3);

        // 测试投诉数据4：关于餐饮价格问题（已结案）
        Complaint complaint4 = new Complaint();
        complaint4.setTitle("景区内餐饮价格过高不合理");
        complaint4.setContent("景区内餐厅的菜品价格明显高于市场价，一份普通套餐要价80元，性价比极低。希望物价部门能介入调查。");
        complaint4.setStatus(ComplaintStatus.CLOSED);
        complaint4.setHandlerComment("已与餐饮商家沟通，要求公示价格并规范定价。");
        complaint4.setClosureComment("商家已调整价格并公示，后续将定期抽查。");
        complaint4.setRating(3);
        complaint4.setProcessedBy(admin);
        complaint4.setCreatedBy(visitor);
        complaintRepository.save(complaint4);
    }

    private void createTestEmergencyInfos(UserAccount admin) {
        if (emergencyInfoRepository.count() > 0) {
            return; // 如果已经有应急信息数据，不再创建
        }

        LocalDateTime now = LocalDateTime.now();

        // 测试应急信息1：天气预警（已发布）
        EmergencyInfo emergency1 = new EmergencyInfo();
        emergency1.setTitle("暴雨天气预警通知");
        emergency1.setContent("根据气象部门预报，今天下午至夜间将有强降雨天气，景区内部分山路可能湿滑，请游客注意安全。建议调整出行计划，避免前往山区。");
        emergency1.setStatus(EmergencyStatus.PUBLISHED);
        emergency1.setValidFrom(now.minusHours(2));
        emergency1.setValidUntil(now.plusDays(1));
        emergency1.setCreatedBy(admin);
        emergency1.setApprovedBy(admin);
        emergencyInfoRepository.save(emergency1);

        // 测试应急信息2：设备维护通知（待审批）
        EmergencyInfo emergency2 = new EmergencyInfo();
        emergency2.setTitle("缆车设备维护暂停服务通知");
        emergency2.setContent("为保障游客安全，景区缆车将于明日（4月16日）上午8:00-12:00进行定期维护保养，期间暂停运营。请游客合理安排行程。");
        emergency2.setStatus(EmergencyStatus.PENDING_APPROVAL);
        emergency2.setValidFrom(now.plusHours(12));
        emergency2.setValidUntil(now.plusDays(2));
        emergency2.setCreatedBy(admin);
        emergencyInfoRepository.save(emergency2);

        // 测试应急信息3：道路施工通知（草稿）
        EmergencyInfo emergency3 = new EmergencyInfo();
        emergency3.setTitle("景区东线道路施工通知");
        emergency3.setContent("为改善景区交通条件，4月17日-4月20日景区东线道路将进行路面修复施工，施工期间该路段将临时封闭。建议游客绕行西线。");
        emergency3.setStatus(EmergencyStatus.DRAFT);
        emergency3.setValidFrom(now.plusDays(2));
        emergency3.setValidUntil(now.plusDays(5));
        emergency3.setCreatedBy(admin);
        emergencyInfoRepository.save(emergency3);

        // 测试应急信息4：防火安全提醒（已发布）
        EmergencyInfo emergency4 = new EmergencyInfo();
        emergency4.setTitle("春季防火安全重要提醒");
        emergency4.setContent("春季气候干燥，景区内严禁吸烟、使用明火。请游客严格遵守防火规定，共同维护景区生态环境安全。");
        emergency4.setStatus(EmergencyStatus.PUBLISHED);
        emergency4.setValidFrom(now.minusDays(1));
        emergency4.setValidUntil(now.plusMonths(1));
        emergency4.setCreatedBy(admin);
        emergency4.setApprovedBy(admin);
        emergencyInfoRepository.save(emergency4);
    }
}
