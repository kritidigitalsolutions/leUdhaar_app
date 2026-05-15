class DashboardResModel {
  DashboardResModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final Data? data;

  factory DashboardResModel.fromJson(Map<String, dynamic> json) {
    return DashboardResModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({
    required this.period,
    required this.filters,
    required this.lending,
    required this.borrowing,
  });

  final String? period;
  final List<String> filters;
  final Lending? lending;
  final Borrowing? borrowing;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      period: json["period"],
      filters: json["filters"] == null
          ? []
          : List<String>.from(json["filters"]!.map((x) => x)),
      lending: json["lending"] == null
          ? null
          : Lending.fromJson(json["lending"]),
      borrowing: json["borrowing"] == null
          ? null
          : Borrowing.fromJson(json["borrowing"]),
    );
  }
}

class Borrowing {
  Borrowing({
    required this.cards,
    required this.peopleTitle,
    required this.people,
  });

  final BorrowingCards? cards;
  final String? peopleTitle;
  final List<dynamic> people;

  factory Borrowing.fromJson(Map<String, dynamic> json) {
    return Borrowing(
      cards: json["cards"] == null
          ? null
          : BorrowingCards.fromJson(json["cards"]),
      peopleTitle: json["peopleTitle"],
      people: json["people"] == null
          ? []
          : List<dynamic>.from(json["people"]!.map((x) => x)),
    );
  }
}

class BorrowingCards {
  BorrowingCards({
    required this.totalOwed,
    required this.repaid,
    required this.remaining,
    required this.nextDue,
  });

  final int? totalOwed;
  final int? repaid;
  final int? remaining;
  final int? nextDue;

  factory BorrowingCards.fromJson(Map<String, dynamic> json) {
    return BorrowingCards(
      totalOwed: json["totalOwed"],
      repaid: json["repaid"],
      remaining: json["remaining"],
      nextDue: json["nextDue"],
    );
  }
}

class Lending {
  Lending({
    required this.cards,
    required this.peopleTitle,
    required this.people,
  });

  final LendingCards? cards;
  final String? peopleTitle;
  final List<Person> people;

  factory Lending.fromJson(Map<String, dynamic> json) {
    return Lending(
      cards: json["cards"] == null
          ? null
          : LendingCards.fromJson(json["cards"]),
      peopleTitle: json["peopleTitle"],
      people: json["people"] == null
          ? []
          : List<Person>.from(json["people"]!.map((x) => Person.fromJson(x))),
    );
  }
}

class LendingCards {
  LendingCards({
    required this.totalLent,
    required this.recovered,
    required this.pending,
    required this.overdue,
  });

  final int? totalLent;
  final int? recovered;
  final int? pending;
  final int? overdue;

  factory LendingCards.fromJson(Map<String, dynamic> json) {
    return LendingCards(
      totalLent: json["totalLent"],
      recovered: json["recovered"],
      pending: json["pending"],
      overdue: json["overdue"],
    );
  }
}

class Person {
  Person({
    required this.id,
    required this.agreementId,
    required this.moneyRequestId,
    required this.user,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.repaymentMode,
    required this.displayStatus,
    required this.initials,
  });

  final String? id;
  final dynamic agreementId;
  final String? moneyRequestId;
  final DashboardUser? user;
  final int? amount;
  final DateTime? dueDate;
  final String? status;
  final String? repaymentMode;
  final String? displayStatus;
  final String? initials;

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json["_id"],
      agreementId: json["agreementId"],
      moneyRequestId: json["moneyRequestId"],
      user: json["user"] == null ? null : DashboardUser.fromJson(json["user"]),
      amount: json["amount"],
      dueDate: DateTime.tryParse(json["dueDate"] ?? ""),
      status: json["status"],
      repaymentMode: json["repaymentMode"],
      displayStatus: json["displayStatus"],
      initials: json["initials"],
    );
  }
}

class DashboardUser {
  DashboardUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.profileImage,
  });

  final String? id;
  final String? fullName;
  final String? phone;
  final String? profileImage;

  factory DashboardUser.fromJson(Map<String, dynamic> json) {
    return DashboardUser(
      id: json["_id"],
      fullName: json["fullName"],
      phone: json["phone"],
      profileImage: json["profileImage"],
    );
  }
}
