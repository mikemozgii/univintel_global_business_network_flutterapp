class Job  {
  String id;
  String name;
  String description;
  String locations;
  String contactId;
  int salaryMin;
  int salaryMax;
  String typePosition;
  String companyId;
  String accountId;
  String skills;
  String workedExperience;

  Job() {
    id = null;
  }

  Job.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      name = json['name'],
      description = json['description'],
      locations = json['locations'],
      contactId = json['contactId'],
      salaryMin = json['salaryMin'],
      salaryMax = json['salaryMax'],
      companyId = json['companyId'],
      accountId = json['accountId'],
      skills = json['skills'],
      workedExperience = json['workedExperience'],
      typePosition = json['typePosition'];

  toJson() {
    return {
      'id': id == null ? '00000000-0000-0000-0000-000000000000' : id,
      'name': name,
      'description': description,
      'locations': locations,
      'contactId': contactId,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'typePosition': typePosition,
      'skills': skills,
      'workedExperience': workedExperience,
      'accountId': accountId == null ? '00000000-0000-0000-0000-000000000000' : accountId,
      'companyId': companyId == null ? '00000000-0000-0000-0000-000000000000' : companyId,
    };
  }

}