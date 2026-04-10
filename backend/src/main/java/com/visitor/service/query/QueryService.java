package com.visitor.service.query;

import com.visitor.service.query.dto.SimpleItem;
import com.visitor.service.query.dto.WeatherTrafficResponse;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class QueryService {

    public List<SimpleItem> starHotels() {
        return List.of(
                new SimpleItem("sh-1", "Sunrise International Hotel", "4-star hotel with 120 rooms"),
                new SimpleItem("sh-2", "Lakeview Resort Hotel", "5-star hotel near scenic lake")
        );
    }

    public List<SimpleItem> nonStarHotels() {
        return List.of(
                new SimpleItem("nh-1", "Pine Village Guesthouse", "Local guesthouse in village area"),
                new SimpleItem("nh-2", "Mountain Stay Inn", "Budget inn near route A")
        );
    }

    public List<SimpleItem> scenicSpots() {
        return List.of(
                new SimpleItem("sp-1", "Cloud Peak", "Main scenic viewpoint"),
                new SimpleItem("sp-2", "Ancient Town Street", "Historic walking area")
        );
    }

    public List<SimpleItem> routes() {
        return List.of(
                new SimpleItem("rt-1", "Family Day Route", "Scenic spots + dining route"),
                new SimpleItem("rt-2", "Adventure Route", "Mountain and lake trail route")
        );
    }

    public List<SimpleItem> diningAndEntertainment() {
        return List.of(
                new SimpleItem("de-1", "River Taste Restaurant", "Local cuisine and family menu"),
                new SimpleItem("de-2", "Night Music Plaza", "Live music and snack stalls")
        );
    }

    public List<SimpleItem> performances() {
        return List.of(
                new SimpleItem("pf-1", "Folk Dance Group", "Performance every weekend"),
                new SimpleItem("pf-2", "Mountain Drama Team", "Traditional stage performance")
        );
    }

    public WeatherTrafficResponse weatherTraffic() {
        return new WeatherTrafficResponse("Sunny", "26C", "Main road smooth, east gate moderate traffic");
    }
}
