import 'package:flutter/widgets.dart';

import '../data/models/models.dart';
import '../data/repositories/app_repository.dart';
import 'base_viewmodel.dart';

enum DashboardTab { all, complaints, feedbacks, compliments }

class DashboardViewModel extends BaseViewModel {
  DashboardViewModel(this._repository, this._businessId);

  final AppRepository _repository;
  final String _businessId;

  DashboardStats? stats;
  List<Submission> submissions = const [];
  DashboardTab tab = DashboardTab.all;

  List<Submission> get visible {
    return switch (tab) {
      DashboardTab.all => submissions,
      DashboardTab.complaints => submissions
          .where((item) => item.type == SubmissionType.complaint)
          .toList(),
      DashboardTab.feedbacks => submissions
          .where((item) => item.type == SubmissionType.feedback)
          .toList(),
      DashboardTab.compliments => submissions
          .where((item) => item.type == SubmissionType.compliment)
          .toList(),
    };
  }

  @override
  Future<void> init() async {
    setBusy(true);
    try {
      stats = await _repository.fetchStats(_businessId);
      submissions = await _repository.fetchSubmissions(_businessId);
    } on Object {
      setError('Unable to load the dashboard.');
    } finally {
      setBusy(false);
    }
  }

  void selectTab(DashboardTab value) {
    tab = value;
    notifyListeners();
  }
}

class SubmissionsListViewModel extends BaseViewModel {
  SubmissionsListViewModel(
    this._repository,
    this._businessId, {
    this.filter,
  });

  final AppRepository _repository;
  final String _businessId;
  final SubmissionType? filter;

  List<Submission> items = const [];

  @override
  Future<void> init() async {
    setBusy(true);
    try {
      final all = await _repository.fetchSubmissions(_businessId);
      items = filter == null
          ? all
          : all.where((item) => item.type == filter).toList();
    } on Object {
      setError('Unable to load submissions.');
    } finally {
      setBusy(false);
    }
  }
}

class CustomersViewModel extends BaseViewModel {
  CustomersViewModel(this._repository, this._businessId);

  final AppRepository _repository;
  final String _businessId;
  List<Customer> customers = const [];

  @override
  Future<void> init() async {
    setBusy(true);
    try {
      final all = await _repository.fetchSubmissions(_businessId);
      final seen = <String>{};
      customers = [
        for (final item in all)
          if (seen.add(item.customerName))
            Customer(name: item.customerName, lastSubject: item.subject),
      ];
    } on Object {
      setError('Unable to load customers.');
    } finally {
      setBusy(false);
    }
  }
}

class ProfileViewModel extends BaseViewModel {
  ProfileViewModel(this._repository, this.business);

  final AppRepository _repository;
  Business business;

  late String name;
  late String email;
  late String phone;
  bool saved = false;

  @override
  Future<void> init() async {
    name = business.name;
    email = business.email;
    phone = business.phone;
    notifyListeners();
  }

  void updateName(String value) {
    name = value;
    saved = false;
    notifyListeners();
  }

  void updateEmail(String value) {
    email = value;
    saved = false;
    notifyListeners();
  }

  void updatePhone(String value) {
    phone = value;
    saved = false;
    notifyListeners();
  }

  Future<Business?> save() async {
    setBusy(true);
    setError(null);
    try {
      final updated = await _repository.updateBusiness(
        business.copyWith(
          name: name,
          email: email,
          phone: phone,
          initial: name.isEmpty ? business.initial : name[0].toUpperCase(),
        ),
      );
      business = updated;
      saved = true;
      return updated;
    } on Object {
      setError('Unable to save the profile.');
      return null;
    } finally {
      setBusy(false);
    }
  }
}

class QrCodesViewModel extends BaseViewModel {
  QrCodesViewModel(this.link);

  final String link;
}

class UniqueLinkViewModel extends BaseViewModel {
  UniqueLinkViewModel(
    this._repository,
    this._businessId,
    String currentLink,
  )   : link = currentLink,
        draft = currentLink,
        controller = TextEditingController(text: currentLink);

  final AppRepository _repository;
  final String _businessId;
  final TextEditingController controller;
  String link;
  String draft;
  bool saved = false;
  bool copied = false;

  void updateDraft(String value) {
    draft = value;
    saved = false;
    notifyListeners();
  }

  void markCopied() {
    copied = true;
    notifyListeners();
  }

  Future<String?> save() async {
    if (draft.trim().isEmpty) {
      setError('Enter a link.');
      return null;
    }
    setBusy(true);
    setError(null);
    try {
      link = await _repository.saveUniqueLink(
        businessId: _businessId,
        link: draft,
      );
      draft = link;
      controller.text = link;
      saved = true;
      return link;
    } on Object {
      setError('Unable to save the link.');
      return null;
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
