using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace HomeBoard.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddGroupAssignments : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<Guid>(
                name: "AssignedToUserId",
                table: "TaskAssignments",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddColumn<int>(
                name: "AssignedToGroup",
                table: "TaskAssignments",
                type: "integer",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AssignedToGroup",
                table: "TaskAssignments");

            migrationBuilder.AlterColumn<Guid>(
                name: "AssignedToUserId",
                table: "TaskAssignments",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);
        }
    }
}
