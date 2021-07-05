class PromoteType {
    int id;
    String name;
    String description;
    String color;
    int days;
    bool customDays;
    double price;
    DateTime dateStart;
    DateTime dateEnd;

    PromoteType({
        this.id,
        this.name,
        this.description,
        this.color,
        this.days,
        this.customDays,
        this.price,
        this.dateStart,
        this.dateEnd,
    });

    factory PromoteType.fromJson(Map<String, dynamic> json) => PromoteType(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        color: json["color"],
        days: json["days"],
        customDays: json["customDays"],
        price: json["price"].toDouble(),
        dateStart: DateTime.parse(json["dateStart"]),
        dateEnd: json["dateEnd"] == null ? null : DateTime.parse(json["dateEnd"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "days": days,
        "customDays": customDays,
        "price": price,
        "dateStart": dateStart.toIso8601String(),
        "dateEnd": dateEnd.toIso8601String(),
    };
}