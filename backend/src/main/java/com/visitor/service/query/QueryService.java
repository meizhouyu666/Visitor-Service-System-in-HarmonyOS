package com.visitor.service.query;

import com.visitor.service.query.dto.*;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.NoSuchElementException;

@Service
public class QueryService {

    // ===================== 酒店 =====================
    public List<HotelResponse> starHotels(Integer star, Integer minPrice, Integer maxPrice, Boolean hasBreakfast) {
        return starHotelList().stream()
                .filter(h -> star == null || h.star().equals(star))
                .filter(h -> minPrice == null || h.price() >= minPrice)
                .filter(h -> maxPrice == null || h.price() <= maxPrice)
                .filter(h -> hasBreakfast == null || h.hasBreakfast().equals(hasBreakfast))
                .toList();
    }

    public List<HotelResponse> nonStarHotels(Integer minPrice, Integer maxPrice) {
        return nonStarHotelList().stream()
                .filter(h -> minPrice == null || h.price() >= minPrice)
                .filter(h -> maxPrice == null || h.price() <= maxPrice)
                .toList();
    }

    public List<HotelResponse> starHotelList() {
        return List.of(
                new HotelResponse("sh-1", "日出国际大酒店", "景区中心大道1号", 5, 688, "400-123-4567", 4.8, true, "免费停车、泳池、健身房", "高端湖景度假酒店，设施齐全"),
                new HotelResponse("sh-2", "湖景度假酒店", "湖畔路88号", 4, 428, "400-987-6543", 4.6, true, "湖景房、早餐、接送服务", "景区热门四星酒店")
        );
    }

    public List<HotelResponse> nonStarHotelList() {
        return List.of(
                new HotelResponse("nh-1", "松林村民宿", "山村路23号", 0, 168, "138-0000-0001", 4.5, false, "农家小院、免费WiFi", "本地特色民宿，温馨舒适"),
                new HotelResponse("nh-2", "山景客栈", "登山口旁", 0, 128, "139-0000-0002", 4.2, false, "24小时热水、观景阳台", "性价比高的登山客栈")
        );
    }

    public HotelResponse hotelDetail(String id) {
        return starHotelList().stream()
                .filter(h -> h.id().equals(id))
                .findFirst()
                .orElse(nonStarHotelList().stream()
                        .filter(h -> h.id().equals(id))
                        .findFirst()
                        .orElseThrow(() -> new NoSuchElementException("酒店不存在")));
    }

    // ===================== 景点 =====================
    public List<ScenicSpotResponse> scenicSpots(String type, Boolean isFree) {
        return scenicSpotList().stream()
                .filter(s -> type == null || s.type().equals(type))
                .filter(s -> isFree == null || s.isFree().equals(isFree))
                .toList();
    }

    public List<ScenicSpotResponse> scenicSpotList() {
        return List.of(
                new ScenicSpotResponse("sp-1", "云顶观景台", "仙境景区", "山顶核心区", "08:00-18:00", 60, "AAAA", "自然景观", false, "海拔最高观景台，俯瞰全景"),
                new ScenicSpotResponse("sp-2", "古街小镇", "仙境景区", "东区入口", "全天开放", 0, "AAA", "人文历史", true, "百年古街，民俗文化集中地")
        );
    }

    public ScenicSpotResponse scenicSpotDetail(String id) {
        return scenicSpotList().stream()
                .filter(s -> s.id().equals(id))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("景点不存在"));
    }

    // ===================== 路线 =====================
    public List<TravelRouteResponse> routes(String difficulty) {
        return routeList().stream()
                .filter(r -> difficulty == null || r.difficulty().equalsIgnoreCase(difficulty))
                .toList();
    }

    public List<TravelRouteResponse> routeList() {
        return List.of(
                new TravelRouteResponse("rt-1", "亲子休闲一日游", 6, "简单", "家庭/老人", "古街 → 湖景 → 博物馆", "轻松不累，适合全家出行，全程平缓步道"),
                new TravelRouteResponse("rt-2", "登山探险路线", 8, "困难", "年轻人/登山爱好者", "云顶 → 峡谷 → 瀑布", "全程徒步，风景壮观，需一定体力")
        );
    }

    public TravelRouteResponse routeDetail(String id) {
        return routeList().stream()
                .filter(r -> r.id().equals(id))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("路线不存在"));
    }

    // ===================== 餐饮 =====================
    public List<DiningResponse> dining(String type, Integer minPrice, Integer maxPrice) {
        return diningList().stream()
                .filter(d -> type == null || d.type().equals(type))
                .filter(d -> minPrice == null || d.avgPrice() >= minPrice)
                .filter(d -> maxPrice == null || d.avgPrice() <= maxPrice)
                .toList();
    }

    public List<DiningResponse> diningList() {
        return List.of(
                new DiningResponse("dn-1", "河味餐厅", "中餐", 68, "10:00-22:00", "景区中段", "土家鸡、河鲜鱼汤", "本地特色菜，食材新鲜，口碑很好"),
                new DiningResponse("dn-2", "老街小吃铺", "小吃", 35, "08:00-24:00", "古街内", "豆腐脑、烤肠、糍粑", "平价小吃，游客必打卡")
        );
    }

    public DiningResponse diningDetail(String id) {
        return diningList().stream()
                .filter(d -> d.id().equals(id))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("餐饮不存在"));
    }

    // ===================== 娱乐 =====================
    public List<EntertainmentResponse> entertainment() {
        return List.of(
                new EntertainmentResponse("et-1", "竹筏漂流", "体验类", "湖畔码头", "09:00-17:00", 80, "轻松惬意，适合全家体验"),
                new EntertainmentResponse("et-2", "森林小火车", "观光类", "山顶环线", "10:00-16:00", 50, "穿越森林，观景绝佳")
        );
    }

    public EntertainmentResponse entertainmentDetail(String id) {
        return entertainment().stream()
                .filter(e -> e.id().equals(id))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("娱乐项目不存在"));
    }

    // ===================== 演出 =====================
    public List<PerformanceResponse> performances(Integer minPrice, Integer maxPrice) {
        return performanceList().stream()
                .filter(p -> minPrice == null || p.price() >= minPrice)
                .filter(p -> maxPrice == null || p.price() <= maxPrice)
                .toList();
    }

    public List<PerformanceResponse> performanceList() {
        return List.of(
                new PerformanceResponse("pf-1", "民俗歌舞秀", "中心广场", LocalDateTime.of(2026, 4, 15, 19, 30), 80, "民族歌舞团", "大型实景民俗演出，非常震撼"),
                new PerformanceResponse("pf-2", "山水实景剧", "湖畔剧场", LocalDateTime.of(2026, 4, 15, 20, 0), 120, "山水演艺公司", "灯光+山水+表演，必看演出")
        );
    }

    public PerformanceResponse performanceDetail(String id) {
        return performanceList().stream()
                .filter(p -> p.id().equals(id))
                .findFirst()
                .orElseThrow(() -> new NoSuchElementException("演出不存在"));
    }

    // ===================== 天气 =====================
    public List<WeatherResponse> weather(LocalDate date) {
        List<WeatherResponse> list = weatherList();
        if (date == null) return list;
        return list.stream().filter(w -> w.date().isEqual(date)).toList();
    }

    public List<WeatherResponse> weatherList() {
        return List.of(
                new WeatherResponse(LocalDate.now(), "晴", "26℃", "东南风2级", 65, "适合出游"),
                new WeatherResponse(LocalDate.now().plusDays(1), "多云", "24℃", "东风2级", 70, "适宜户外活动"),
                new WeatherResponse(LocalDate.now().plusDays(2), "晴", "28℃", "南风3级", 60, "天气炎热，注意防晒")
        );
    }

    // ===================== 交通 =====================
    public TrafficResponse traffic() {
        return new TrafficResponse(
                "你的位置",
                "仙境景区游客中心",
                "畅通",
                "高速 → 景区大道 → 游客中心",
                "预计40分钟"
        );
    }
}