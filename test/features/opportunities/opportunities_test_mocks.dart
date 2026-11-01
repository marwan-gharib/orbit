import 'package:mocktail/mocktail.dart';

import 'package:orbit/core/services/crm_data_change.dart';
import 'package:orbit/core/services/crm_data_change_service.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_customer_entity.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_employee_entity.dart';
import 'package:orbit/features/opportunities/domain/entities/opportunity_entity.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_stage.dart';
import 'package:orbit/features/opportunities/domain/enums/opportunity_status.dart';
import 'package:orbit/features/opportunities/domain/params/get_opportunities_params.dart';
import 'package:orbit/features/opportunities/domain/params/opportunities_criteria.dart';
import 'package:orbit/features/opportunities/domain/repositories/opportunities_repository.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunities_usecase.dart';
import 'package:orbit/features/opportunities/domain/usecases/get_opportunity_usecase.dart';
import 'package:orbit/features/opportunities/domain/usecases/watch_crm_changes_usecase.dart';

class MockOpportunitiesRepository extends Mock
    implements OpportunitiesRepository {}

class MockGetOpportunitiesUseCase extends Mock
    implements GetOpportunitiesUseCase {}

class MockGetOpportunityUseCase extends Mock implements GetOpportunityUseCase {}

class MockWatchCrmChangesUseCase extends Mock
    implements WatchCrmChangesUseCase {}

class MockCrmDataChangeService extends Mock implements CrmDataChangeService {}

/// Registers mocktail fallbacks once for all opportunities tests.
void registerOpportunitiesFallbacks() {
  registerFallbackValue(
    OpportunitiesCriteria(title: 'ERP', customerId: 1),
  );
  registerFallbackValue(
    GetOpportunitiesParams(
      criteria: const OpportunitiesCriteria(),
      page: 1,
      pageSize: 10,
    ),
  );
  registerFallbackValue(
    const CrmDataChange(kind: CrmDataKind.note, customerId: 0),
  );
  registerFallbackValue(tOpportunity());
}

/// One opportunity under test.
Opportunity tOpportunity({
  int id = 1,
  String title = 'ERP license - 50 seats',
  int customerId = 1,
  int? opportunityId,
}) => Opportunity(
  opportunityId: id,
  title: title,
  estimatedValue: 250000,
  currency: 'EGP',
  stage: OpportunityStage.fromValue('lead'),
  probability: 10,
  expectedCloseDate: DateTime.utc(2027, 3, 31),
  status: OpportunityStatus.fromValue('open'),
  lostReason: '',
  createdAt: DateTime.utc(2026, 10, 26, 11, 53, 40),
  closedAt: null,
  customer: tCustomer(),
  employee: tEmployee(),
);

OpportunityCustomer tCustomer({
  int id = 1,
}) => OpportunityCustomer(
  customerId: id,
  customerCode: 'CUS-2026-9973',
  firstName: 'Omar',
  lastName: 'Ibrahim',
  phone: '01144130977',
  companyName: 'PWC',
  email: 'omar@gmail.com',
  address: 'Cairo',
  leadSource: null,
  createdAt: DateTime.utc(2026, 10, 15, 16, 24, 37),
  updatedAt: DateTime.utc(2026, 10, 15, 16, 24, 37),
  contacts: [],
  notes: [],
  interactions: [],
);

OpportunityEmployee tEmployee() => OpportunityEmployee(
  employeeId: 22,
  employeeName: 'Omar Mohammed',
);

Map<String, dynamic> tOpportunityJson({
  int id = 1,
  String stage = 'lead',
  String status = 'open',
}) => <String, dynamic>{
  'opportunity_id': id,
  'title': 'ERP license - 50 seats',
  'estimated_value': 250000,
  'currency': 'EGP',
  'stage': stage,
  'probability': 10,
  'expected_close_date': '2027-03-31',
  'status': status,
  'lost_reason': '',
  'created_at': '2026-10-26T11:53:40.223511Z',
  'closed_at': null,
  'customer': tCustomerJson(),
  'employee': {'employee_id': 22, 'employee_name': 'Omar Mohammed'},
};

Map<String, dynamic> tCustomerJson() => <String, dynamic>{
  'customer_id': 1,
  'customer_code': 'CUS-2026-9973',
  'first_name': 'Omar',
  'last_name': 'Ibrahim',
  'phone': '01144130977',
  'company_name': 'PWC',
  'email': 'omar@gmail.com',
  'address': 'Cairo',
  'lead_source': null,
  'created_at': '2026-10-15T16:24:37.340176Z',
  'updated_at': '2026-10-15T16:24:37.419886Z',
  'contacts': [],
  'notes': [],
  'interactions': [],
};

Map<String, dynamic> tPageResponseJson({
  int count = 1,
  String? next,
  List<Map<String, dynamic>>? results,
}) => <String, dynamic>{
  'count': count,
  'next': next,
  'previous': null,
  'results': results ?? [tOpportunityJson()],
};
