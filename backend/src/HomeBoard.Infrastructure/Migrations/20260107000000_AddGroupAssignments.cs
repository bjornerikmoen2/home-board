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
            // Make AssignedToUserId nullable
            migrationBuilder.AlterColumn<Guid>(
                name: "AssignedToUserId",
                table: "TaskAssignments",
                type: "uniqueidentifier",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier");

            // Add AssignedToGroup column
            migrationBuilder.AddColumn<int>(
                name: "AssignedToGroup",
                table: "TaskAssignments",
                type: "int",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Remove AssignedToGroup column
            migrationBuilder.DropColumn(
                name: "AssignedToGroup",
                table: "TaskAssignments");

            // Make AssignedToUserId non-nullable again
            migrationBuilder.AlterColumn<Guid>(
                name: "AssignedToUserId",
                table: "TaskAssignments",
                type: "uniqueidentifier",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uniqueidentifier",
                oldNullable: true);
        }
    }
}
