import 'package:movie_app/core/constants/api_constants.dart';

class Person {
  final int id;
  final String name;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final String? placeOfBirth;
  final String? profilePath;
  final String? knownForDepartment;
  final double popularity;
  final List<String>? alsoKnownAs;

  Person({
    required this.id,
    required this.name,
    this.biography,
    this.birthday,
    this.deathday,
    this.placeOfBirth,
    this.profilePath,
    this.knownForDepartment,
    this.popularity = 0,
    this.alsoKnownAs,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as int,
      name: json['name'] as String,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      profilePath: json['profile_path'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0,
      alsoKnownAs: (json['also_known_as'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  String? get profileUrl =>
      profilePath != null ? '${ApiConstants.posterW500}$profilePath' : null;

  String get birthYear {
    if (birthday == null || birthday!.isEmpty) return '';
    return birthday!.split('-').first;
  }

  String get deathYear {
    if (deathday == null || deathday!.isEmpty) return '';
    return deathday!.split('-').first;
  }

  String get yearsActive {
    if (birthYear.isEmpty) return '';
    if (deathYear.isNotEmpty) return '$birthYear - $deathYear';
    return '$birthYear -';
  }

  int? get age {
    if (birthday == null || birthday!.isEmpty) return null;
    final birth = DateTime.tryParse(birthday!);
    if (birth == null) return null;

    final now = deathday != null && deathday!.isNotEmpty
        ? DateTime.tryParse(deathday!) ?? DateTime.now()
        : DateTime.now();

    int age = now.year - birth.year;
    if (now.month < birth.month ||
        (now.month == birth.month && now.day < birth.day)) {
      age--;
    }
    return age;
  }
}

class PersonCredit {
  final int id;
  final String title;
  final String? character;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;
  final String mediaType;

  PersonCredit({
    required this.id,
    required this.title,
    this.character,
    this.posterPath,
    this.releaseDate,
    this.voteAverage = 0,
    this.mediaType = 'movie',
  });

  factory PersonCredit.fromJson(Map<String, dynamic> json) {
    return PersonCredit(
      id: json['id'] as int,
      title: (json['title'] ?? json['name'] ?? '') as String,
      character: json['character'] as String?,
      posterPath: json['poster_path'] as String?,
      releaseDate: (json['release_date'] ?? json['first_air_date']) as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      mediaType: (json['media_type'] ?? 'movie') as String,
    );
  }

  String? get posterUrl =>
      posterPath != null ? '${ApiConstants.posterW342}$posterPath' : null;

  String get year {
    if (releaseDate == null || releaseDate!.isEmpty) return '';
    return releaseDate!.split('-').first;
  }

  String get ratingText => voteAverage.toStringAsFixed(1);
}
