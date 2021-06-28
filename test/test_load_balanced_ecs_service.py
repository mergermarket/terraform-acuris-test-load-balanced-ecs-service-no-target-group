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

    def test_no_target_group_pack_and_distinct_instance(self):
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

    def test_service_with_grace_period(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.service_with_grace_period',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)

    def test_no_target_group_service_with_grace_period(self):
        # Given When
        check_call([
            'terraform',
            'plan',
            '-out=plan.out',
            '-no-color',
            '-target=module.no_target_group_service_with_grace_period',
            'test/infra'
        ])

        resource_changes = self.get_resource_changes()

        # Then
        assert len(resource_changes) == 3
        self.assert_resource_changes_action(resource_changes, 'create', 3)