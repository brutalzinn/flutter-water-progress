class Weight {
  final double value;

  Weight({
    required this.value,
  });

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      value: json['value'].toDouble(),
    );
  }
}

class Response {
  String? type = "response";
  final Weight weight;

  Response({
    this.type,
    required this.weight,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      type: json['type'],
      weight: Weight.fromJson(json['value']),
    );
  }
}
