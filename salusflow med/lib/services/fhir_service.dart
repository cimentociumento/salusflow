import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:salusflow/database/database_helper.dart';

class FhirService extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  Future<Map<String, dynamic>> _patientToFhir(Map<String, dynamic> user) async {
    return {
      'resourceType': 'Patient',
      'identifier': [
        {
          'system': 'http://hl7.org/fhir/sid/br-cpf-cnpj',
          'value': user['cpf_cnpj'],
        }
      ],
      'name': [
        {
          'use': 'official',
          'text': user['name'],
        }
      ],
      'telecom': [
        if (user['email'] != null && (user['email'] as String).isNotEmpty)
          {
            'system': 'email',
            'value': user['email'],
          }
      ],
      'birthDate': user['birth_date'],
    };
  }

  Future<Map<String, dynamic>> _medicalRecordToFhir(Map<String, dynamic> record, Map<String, dynamic> user) async {
    return {
      'resourceType': 'Observation',
      'status': 'final',
      'subject': {
        'reference': 'Patient/${user['cpf_cnpj']}',
        'display': user['name'],
      },
      'category': [
        {
          'coding': [
            {'system': 'http://terminology.hl7.org/CodeSystem/observation-category', 'code': 'social-history'}
          ]
        }
      ],
      'component': [
        if (record['allergies'] != null)
          {
            'code': {'text': 'Allergies'},
            'valueString': record['allergies']
          },
        if (record['diagnoses'] != null)
          {
            'code': {'text': 'Diagnoses'},
            'valueString': record['diagnoses']
          },
        if (record['medications'] != null)
          {
            'code': {'text': 'Medications'},
            'valueString': record['medications']
          },
        if (record['blood_type'] != null)
          {
            'code': {'text': 'Blood type'},
            'valueString': record['blood_type']
          },
        if (record['vaccination_card'] != null)
          {
            'code': {'text': 'Vaccination card'},
            'valueString': record['vaccination_card']
          },
        if (record['authorize_transfusion'] != null)
          {
            'code': {'text': 'Authorize transfusion'},
            'valueBoolean': record['authorize_transfusion'] == 1
          },
        if (record['observations'] != null)
          {
            'code': {'text': 'Observations'},
            'valueString': record['observations']
          }
      ]
    };
  }

  Future<Map<String, dynamic>> _permissionToFhir(Map<String, dynamic> permission, Map<String, dynamic> user) async {
    return {
      'resourceType': 'Consent',
      'status': (permission['is_active'] == 1) ? 'active' : 'inactive',
      'patient': {
        'reference': 'Patient/${user['cpf_cnpj']}',
        'display': user['name'],
      },
      'provision': {
        'type': 'permit',
        'actor': [
          {
            'role': {'text': 'Practitioner'},
            'reference': {
              'reference': 'Practitioner/${permission['doctor_id']}',
              'display': permission['doctor_name'],
            }
          }
        ],
      },
    };
  }

  Future<Map<String, List<Map<String, dynamic>>>> exportUserBundle(int userId) async {
    final user = await _db.getUserByCpfCnpj((await _db.getMedicalRecordByUserId(userId))?['user_id'].toString() ?? '');
    final record = await _db.getMedicalRecordByUserId(userId);
    final permissions = await _db.getUserDoctorPermissions(userId);

    if (user == null) {
      return {'Patient': [], 'Observation': [], 'Consent': []};
    }

    final patient = await _patientToFhir(user);
    final observation = record != null ? await _medicalRecordToFhir(record, user) : null;
    final consents = <Map<String, dynamic>>[];
    for (final p in permissions) {
      consents.add(await _permissionToFhir(p, user));
    }

    return {
      'Patient': [patient],
      'Observation': observation != null ? [observation] : [],
      'Consent': consents,
    };
  }

  Future<bool> syncToRemote(int userId) async {
    final bundle = await exportUserBundle(userId);
    // Aqui faríamos POST/PUT em um servidor FHIR. Por enquanto, apenas log.
    debugPrint('FHIR Export Bundle => ${jsonEncode(bundle)}');
    // Simular sucesso
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
