
class LaunchObj{

  final String id;
  final String mission_name;
  final String img;


  LaunchObj({
    this.id,
    this.mission_name,
    this.img


  });

  factory LaunchObj.fromJson(Map<String, dynamic> json){
    if (json == null ){
      return null;
    }
    return new LaunchObj(
        id: json["id"],
        mission_name: json["mission_name"],
        img: json["links"]["flickr_images"][0] ?? "",

    );
  }

}


class LaunchDetailsObj {
  final LaunchObj launchObj;
  final String details;
  final String mission_patch;

  LaunchDetailsObj({
    this.launchObj,
    this.details,
    this.mission_patch
  });

  factory LaunchDetailsObj.fromJson(Map<String, dynamic> json){
    if (json == null ){
      return null;
    }
    return new LaunchDetailsObj(
        launchObj: LaunchObj.fromJson(json),
        details: json["details"],
        mission_patch: json["links"]["mission_patch"]

    );
  }

}