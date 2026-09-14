"""Fail CI on any infrastructure change in an unchanged consumer upgrade."""
import json
import sys

events = [json.loads(line) for line in open(sys.argv[1])]
plans = {e["@testrun"]: e["test_plan"] for e in events if "test_plan" in e}
assert any(e.get("test_summary", {}).get("status") == "pass" for e in events)
upgrade = plans["upgrade"]["resource_changes"]
assert len(upgrade) == 5, upgrade
assert all(r["change"]["actions"] == ["no-op"] for r in upgrade), upgrade
external = plans["external"]["resource_changes"]
assert {r["address"] for r in external} == {
    "aws_ecs_task_definition.test", "aws_iam_role.ecs_task_execution_role",
    "aws_iam_role_policy.secretsAccess",
}, external
print("PASS: unchanged consumer has five no-op resources; external role is unmanaged.")
