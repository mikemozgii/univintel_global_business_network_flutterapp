class LogoFile {
  String id;
  String logoId;

  LogoFile(this.id, this.logoId);

  Map<String, dynamic> toJson() => {
        'id': id,
        'logoId': logoId,
      };
}
