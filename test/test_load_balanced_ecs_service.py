import json
import unittest

from subprocess import check_call, check_output


class TestCreateTaskdef(unittest.TestCase):

    def setUp(self):
        check_call(['terraform', 'get', 'test/infra'])
        check_call(['terraform', 'init', 'test/infra'])

    def get_output_json(self):
        return json.loads(check_output([
            'terraform',
            'show',
            '-json',
            'plan.out'
        ]).decode('utf-8'))

    def get_resource_changes(self):
        output = self.get_output_json()
        return output.get('resource_changes')

    def assert_resource_changes_action(self, resource_changes, action, length):
        resource_changes_create = [
            rc for rc in resource_changes
            if rc.get('change').get('actions') == [action]
        ]
        assert len(resource_changes_create) == length

    def assert_resource_changes(self, testname, resource_changes):
        with open(f'test/files/{testname}.json', 'r') as f:
            data = json.load(f)

            print('from_json_file******************************')
            print(data.get('resource_changes'))
            print('******************************')
            print('Terraform_output******************************')
            print(resource_changes)
            assert data.get('resource_changes') == resource_changes

    def test_create_ecs_service(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)
        self.assert_resource_changes('create_ecs_service', resource_changes)

    def test_create_service_with_long_name(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service_with_long_name',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)
        self.assert_resource_changes(
            'create_service_with_long_name', resource_changes)

    def test_min_and_max_percent(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service_with_custom_min_and_max_percent',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)
        self.assert_resource_changes('min_and_max_percent', resource_changes)

    def test_no_target_group(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.no_target_group',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)
        self.assert_resource_changes('no_target_group', resource_changes)

    def test_pack_and_distinct_instance(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service_with_pack_and_distinct_task_placement',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)
        self.assert_resource_changes('create_service_with_pack_and_distinct_task_placement', resource_changes)

    def test_pack_and_distinct_instance(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.no_target_group_pack_and_distinct_task_placement',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)
        self.assert_resource_changes('no_target_group_pack_and_distinct_task_placement', resource_changes)